#!/usr/bin/env python3
"""Upload and submit an APK to Huawei AppGallery via the AppGallery Connect API.

Sequence:
  1. POST /oauth2/v1/token                  -> access token
  2. GET  /publish/v2/upload-url/for-obs    -> a one-shot OBS upload URL
  3. PUT  <obs url>                         -> the APK bytes
  4. POST /publish/v2/app-file-info/update  -> attach the uploaded file to the draft
  5. POST /publish/v2/app-submit            -> put the draft into Huawei's review queue

Every AGC call logs its HTTP status and response body before it is checked, so a
failed run is diagnosable from the workflow log alone. AGC also returns HTTP 200
with a non-zero `ret.code` for business errors, so both layers are checked.

Required environment:
  HUAWEI_CLIENT_ID, HUAWEI_CLIENT_SECRET, HUAWEI_APP_ID, HUAWEI_APK_PATH
Optional:
  HUAWEI_APP_VERSION  - only used to make error messages legible
  HUAWEI_RELEASE_TYPE - 1 = full release (default)

AppGallery Connect prerequisites for the credentials (console-side, one time):
  * The AppGallery Connect API must be enabled for the account
    (Users and permissions -> API management).
  * The API client behind HUAWEI_CLIENT_ID must be team/project level, not personal.
  * That client needs a publishing role (App administrator, or equivalent with
    App release rights), scoped to the app matching HUAWEI_APP_ID.
  A token that authenticates but gets "client token auth failed" (401) or
  "client token authorization fail." (403) on the first publishing call means one
  of the three above is missing. Both were observed on this repo before the
  console was configured.
"""

import hashlib
import os
import sys
import time

import requests

DOMAIN = "https://connect-api.cloud.huawei.com/api"
OBS_UPLOAD_ATTEMPTS = 3
OBS_RETRY_DELAY_SECONDS = 5


class PublishError(Exception):
    """A failure we can explain to a human without a traceback."""


def log_response(label, resp):
    body = resp.text
    if len(body) > 4000:
        body = body[:4000] + "... [truncated]"
    print(f"{label}: HTTP {resp.status_code} {body}", flush=True)


def check(label, resp):
    """Fail on an HTTP error or on a non-zero AGC ret.code."""
    log_response(label, resp)

    if resp.status_code in (401, 403) or "client token" in resp.text.lower():
        raise PublishError(
            f"{label} was rejected: the OAuth token is valid but is not authorised to "
            f"publish this app.\n"
            f"This is an AppGallery Connect console configuration problem, not a bad secret. Check:\n"
            f"  1. The AppGallery Connect API is enabled (Users and permissions -> API management).\n"
            f"  2. The API client behind HUAWEI_CLIENT_ID is team/project level, not personal.\n"
            f"  3. That client has a publishing role (App administrator / App release) scoped to "
            f"HUAWEI_APP_ID.\n"
            f"Response: HTTP {resp.status_code} {resp.text}"
        )

    if not resp.ok:
        raise PublishError(f"{label} failed: HTTP {resp.status_code} {resp.text}")

    try:
        payload = resp.json()
    except ValueError:
        raise PublishError(f"{label} returned a non-JSON body: {resp.text}")

    ret = payload.get("ret") or {}
    code = ret.get("code", 0)
    if code:
        msg = ret.get("msg", "")
        raise PublishError(explain_agc_error(label, code, msg))

    return payload


def explain_agc_error(label, code, msg):
    lowered = (msg or "").lower()
    version = os.environ.get("HUAWEI_APP_VERSION", "").strip()
    version_note = f" (this build is version {version})" if version else ""

    if "exist" in lowered and ("version" in lowered or "file" in lowered or "package" in lowered):
        return (
            f"{label} failed: AppGallery already has this version{version_note}.\n"
            f"AppGallery rejects a re-upload of an existing versionCode. Bump the build number "
            f"and dispatch again, or remove the existing draft in the AppGallery Connect console.\n"
            f"AGC ret.code={code} msg={msg}"
        )

    if "review" in lowered or "submit" in lowered:
        return (
            f"{label} failed: AppGallery would not accept the submission{version_note}. "
            f"A previous build of this app may already be in the review queue.\n"
            f"AGC ret.code={code} msg={msg}"
        )

    return f"{label} failed: AGC ret.code={code} msg={msg}{version_note}"


def get_token(client_id, client_secret):
    resp = requests.post(
        f"{DOMAIN}/oauth2/v1/token",
        json={
            "client_id": client_id,
            "client_secret": client_secret,
            "grant_type": "client_credentials",
        },
        timeout=60,
    )
    payload = check("token", resp)
    token = payload.get("access_token")
    if not token:
        raise PublishError(f"token call returned no access_token: {resp.text}")
    print("Token obtained successfully", flush=True)
    return token


def get_upload_url(headers, app_id, file_name, file_size, sha256, release_type):
    resp = requests.get(
        f"{DOMAIN}/publish/v2/upload-url/for-obs",
        params={
            "appId": app_id,
            "fileName": file_name,
            "sha256": sha256,
            "contentLength": file_size,
            "releaseType": release_type,
        },
        headers=headers,
        timeout=60,
    )
    payload = check("upload-url/for-obs", resp)
    url_info = payload.get("urlInfo")
    if not url_info or not url_info.get("url"):
        raise PublishError(f"upload-url/for-obs returned no urlInfo: {resp.text}")
    print("Upload URL obtained", flush=True)
    return url_info


def upload_to_obs(url_info, apk_path):
    """PUT the APK, retrying — a blip mid-stream leaves a partial object."""
    last_error = None
    for attempt in range(1, OBS_UPLOAD_ATTEMPTS + 1):
        try:
            with open(apk_path, "rb") as f:
                resp = requests.put(
                    url_info["url"], data=f, headers=url_info.get("headers") or {}, timeout=600
                )
            print(f"OBS upload attempt {attempt}: HTTP {resp.status_code}", flush=True)
            if resp.ok:
                print("File uploaded to OBS", flush=True)
                return
            last_error = f"HTTP {resp.status_code} {resp.text}"
        except requests.RequestException as exc:
            last_error = str(exc)
            print(f"OBS upload attempt {attempt} raised: {exc}", flush=True)

        if attempt < OBS_UPLOAD_ATTEMPTS:
            time.sleep(OBS_RETRY_DELAY_SECONDS)

    raise PublishError(
        f"Uploading the APK to OBS failed after {OBS_UPLOAD_ATTEMPTS} attempts: {last_error}"
    )


def attach_file(headers, app_id, url_info, file_name, file_size, sha256, release_type):
    resp = requests.post(
        f"{DOMAIN}/publish/v2/app-file-info/update",
        json={
            "fileType": 5,
            "files": [
                {
                    "fileName": file_name,
                    "fileDestUrl": url_info["url"].split("?")[0],
                    "size": file_size,
                    "sha256": sha256,
                }
            ],
        },
        params={"appId": app_id, "releaseType": release_type},
        headers={**headers, "Content-Type": "application/json"},
        timeout=120,
    )
    check("app-file-info/update", resp)
    print("Upload committed successfully", flush=True)


def submit(headers, app_id, release_type, remark):
    resp = requests.post(
        f"{DOMAIN}/publish/v2/app-submit",
        params={"appId": app_id, "releaseType": release_type, "remark": remark},
        headers={**headers, "Content-Type": "application/json"},
        timeout=120,
    )
    payload = check("app-submit", resp)
    # AGC returns success on submit without the release being live; log whatever
    # state it hands back so the run's log proves what actually happened.
    print(f"Submitted to AppGallery review. AGC response payload: {payload}", flush=True)


def main():
    try:
        client_id = os.environ["HUAWEI_CLIENT_ID"]
        client_secret = os.environ["HUAWEI_CLIENT_SECRET"]
        app_id = os.environ["HUAWEI_APP_ID"]
        apk_path = os.environ["HUAWEI_APK_PATH"]
    except KeyError as exc:
        print(f"Missing required environment variable: {exc}", file=sys.stderr)
        return 1

    release_type = os.environ.get("HUAWEI_RELEASE_TYPE", "1")
    version = os.environ.get("HUAWEI_APP_VERSION", "").strip()
    remark = f"Automated upload of {version}" if version else "Automated upload"

    if not os.path.isfile(apk_path):
        print(f"APK not found at {apk_path}", file=sys.stderr)
        return 1

    file_name = os.path.basename(apk_path)
    file_size = os.path.getsize(apk_path)
    with open(apk_path, "rb") as f:
        sha256 = hashlib.sha256(f.read()).hexdigest()
    print(f"APK {file_name} ({file_size} bytes, sha256 {sha256})", flush=True)

    try:
        access_token = get_token(client_id, client_secret)
        headers = {"Authorization": f"Bearer {access_token}", "client_id": client_id}

        url_info = get_upload_url(headers, app_id, file_name, file_size, sha256, release_type)
        upload_to_obs(url_info, apk_path)
        attach_file(headers, app_id, url_info, file_name, file_size, sha256, release_type)
        submit(headers, app_id, release_type, remark)
    except PublishError as exc:
        print(f"\n::error::Huawei AppGallery publish failed\n{exc}", file=sys.stderr)
        return 1
    except requests.RequestException as exc:
        print(f"\n::error::Huawei AppGallery publish failed: network error: {exc}", file=sys.stderr)
        return 1

    print("Build is in the Huawei AppGallery review queue.", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
