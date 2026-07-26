#!/usr/bin/env python3
"""Upload and submit an APK to Huawei AppGallery via the AppGallery Connect API.

Sequence:
  1. POST /oauth2/v1/token                  -> access token
  2. GET  /publish/v2/upload-url/for-obs    -> a one-shot OBS upload URL
  3. PUT  <obs url>                         -> the APK bytes
  4. PUT  /publish/v2/app-file-info         -> attach the uploaded file to the draft
  5. POST /publish/v2/app-submit            -> put the draft into Huawei's review queue

Every AGC call logs its HTTP status and response body before it is checked, so a
failed run is diagnosable from the workflow log alone. AGC also returns HTTP 200
with a non-zero `ret.code` for business errors, so both layers are checked.

Required environment:
  HUAWEI_CLIENT_ID, HUAWEI_CLIENT_SECRET, HUAWEI_APP_ID, HUAWEI_APK_PATH
Optional:
  HUAWEI_APP_VERSION  - only used to make error messages legible
  HUAWEI_RELEASE_TYPE - 1 = full release (default)

AppGallery Connect prerequisite for the credentials (console-side, one time):

  The API client MUST be team-level. Create it under
  Users and permissions -> API key -> Connect API, and set Project to N/A.

  A client with a project set (its JSON says `"type": "project_client_id"` and
  carries a project_id) authenticates fine and is then refused by EVERY
  publishing endpoint with 403 "client token authorization fail." — including
  account-wide ones that take no appId at all. Publishing is an account-level
  resource, so a project-scoped client cannot reach it no matter which role it
  holds. A correct client's JSON says `"type": "team_client_id"` and has no
  project_id.

  This cost this repo ten failed runs. The role was never the problem: both
  original clients held administrator and both failed identically. If you see
  that 403, check the client's TYPE before anything else.
"""

import hashlib
import os
import re
import sys
import time

import requests

DOMAIN = "https://connect-api.cloud.huawei.com/api"
OBS_UPLOAD_ATTEMPTS = 3
OBS_RETRY_DELAY_SECONDS = 5

# AGC compiles an uploaded package asynchronously and refuses submission until it
# finishes, quoting 3-5 minutes. 12 x 30s allows 6 minutes before giving up.
COMPILING_RET_CODE = 204144727
SUBMIT_ATTEMPTS = 12
SUBMIT_RETRY_DELAY_SECONDS = 30


class PublishError(Exception):
    """A failure we can explain to a human without a traceback."""


def redact(text):
    """Strip AGC access tokens out of anything we are about to print.

    This repository is PUBLIC, so Actions logs are world-readable. GitHub masks
    registered secrets, but the access token is minted at runtime and is not one
    of them — nothing masks it for us by default. It is valid for ~48 hours and
    can publish releases, so it must never reach the log.

    Belt and braces: get_token() also emits ::add-mask:: for the token itself, so
    a path that bypasses this funnel is still covered.
    """
    return re.sub(r'("access_token"\s*:\s*")[^"]*(")', r"\1[redacted]\2", text)


def describe(resp):
    """Status, reason phrase and body, with any token redacted.

    Every AGC response is logged through here, so this is the one choke point
    where a secret could escape into the log.

    The reason phrase matters. AGC returns the 403 authorisation refusal with an
    EMPTY body and puts its only diagnostic ("client token authorization fail.")
    in the reason phrase, so logging the body alone throws that away.
    """
    body = redact(resp.text)
    if len(body) > 4000:
        body = body[:4000] + "... [truncated]"
    return f"HTTP {resp.status_code} {resp.reason or ''} {body}".rstrip()


def log_response(label, resp):
    print(f"{label}: {describe(resp)}", flush=True)


def check(label, resp):
    """Fail on an HTTP error or on a non-zero AGC ret.code."""
    log_response(label, resp)

    detail = f"{resp.reason or ''} {resp.text}".lower()
    if resp.status_code in (401, 403) or "client token" in detail:
        raise PublishError(
            f"{label} was rejected: the OAuth token is valid but is not authorised to "
            f"publish this app.\n"
            f"This is an AppGallery Connect console configuration problem, not a bad secret.\n"
            f"Almost always the API client is PROJECT-level. Publishing is account-level, so a\n"
            f"project-scoped client is refused by every publishing endpoint regardless of role.\n"
            f"Fix: Users and permissions -> API key -> Connect API -> Create, with Project = N/A.\n"
            f"A correct client's JSON says \"type\": \"team_client_id\" and has no project_id;\n"
            f"a broken one says \"type\": \"project_client_id\".\n"
            f"Response: {describe(resp)}"
        )

    if not resp.ok:
        raise PublishError(f"{label} failed: {describe(resp)}")

    try:
        payload = resp.json()
    except ValueError:
        raise PublishError(f"{label} returned a non-JSON body: {describe(resp)}")

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
        raise PublishError(f"token call returned no access_token: {describe(resp)}")
    # Ask the runner to mask the token for the rest of the job. This does not
    # print the token: GitHub consumes the workflow command and renders it as ***.
    # It covers anything that prints the token without going through describe().
    print(f"::add-mask::{token}", flush=True)
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
        raise PublishError(f"upload-url/for-obs returned no urlInfo: {describe(resp)}")
    if not url_info.get("objectId"):
        # attach_file needs it, and its absence would surface much later as an
        # opaque 204144662 rather than here where the cause is obvious.
        raise PublishError(f"upload-url/for-obs returned no objectId: {describe(resp)}")
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
            last_error = describe(resp)
        except requests.RequestException as exc:
            last_error = str(exc)
            print(f"OBS upload attempt {attempt} raised: {exc}", flush=True)

        if attempt < OBS_UPLOAD_ATTEMPTS:
            time.sleep(OBS_RETRY_DELAY_SECONDS)

    raise PublishError(
        f"Uploading the APK to OBS failed after {OBS_UPLOAD_ATTEMPTS} attempts: {last_error}"
    )


def attach_file(headers, app_id, url_info, file_name, file_size, sha256, release_type):
    # PUT /publish/v2/app-file-info — not POST, and no /update suffix. The wrong
    # form returns a bare 404 and was only reachable once auth started working.
    resp = requests.put(
        f"{DOMAIN}/publish/v2/app-file-info",
        json={
            "fileType": 5,
            "files": [
                {
                    "fileName": file_name,
                    # The OBS objectId, NOT the upload URL. Passing the URL (even
                    # with its query string stripped) is accepted as HTTP 200 and
                    # then fails with ret.code 204144662 "[fileURLToDb Exception]".
                    # Verified against the live API: objectId succeeds, the URL
                    # does not. The field name really is fileDestUrl — sending
                    # Huawei's fileDestUlr typo gets "The files url is empty."
                    "fileDestUrl": url_info["objectId"],
                    "size": file_size,
                    "sha256": sha256,
                }
            ],
        },
        params={"appId": app_id, "releaseType": release_type},
        headers={**headers, "Content-Type": "application/json"},
        timeout=120,
    )
    check("app-file-info", resp)
    print("Upload committed successfully", flush=True)


def submit(headers, app_id, release_type, remark):
    """Submit the draft for review, waiting while AGC compiles the package.

    AGC accepts the upload and then processes it asynchronously. Submitting too
    soon returns ret.code 204144727, "The package is being compiled, please try
    again in 3-5 minutes". That is normal, not an error: the upload always
    finishes before compilation does, so a pipeline that uploads and immediately
    submits will hit this on essentially every run. Poll until it clears.
    """
    deadline_attempts = SUBMIT_ATTEMPTS
    for attempt in range(1, deadline_attempts + 1):
        resp = requests.post(
            f"{DOMAIN}/publish/v2/app-submit",
            params={"appId": app_id, "releaseType": release_type, "remark": remark},
            headers={**headers, "Content-Type": "application/json"},
            timeout=120,
        )

        if is_still_compiling(resp):
            waited = (attempt - 1) * SUBMIT_RETRY_DELAY_SECONDS
            print(
                f"app-submit: package still compiling after {waited}s "
                f"(attempt {attempt}/{deadline_attempts}); waiting "
                f"{SUBMIT_RETRY_DELAY_SECONDS}s",
                flush=True,
            )
            time.sleep(SUBMIT_RETRY_DELAY_SECONDS)
            continue

        payload = check("app-submit", resp)
        # AGC returns success on submit without the release being live; log whatever
        # state it hands back so the run's log proves what actually happened.
        print(f"Submitted to AppGallery review. AGC response payload: {payload}", flush=True)
        return

    total = SUBMIT_ATTEMPTS * SUBMIT_RETRY_DELAY_SECONDS
    raise PublishError(
        f"AppGallery was still compiling the package after {total}s "
        f"({SUBMIT_ATTEMPTS} attempts). The APK uploaded and attached successfully, so "
        f"this is a slow compile rather than a bad build: re-dispatch, or submit the "
        f"draft from the AppGallery Connect console."
    )


def is_still_compiling(resp):
    """True for AGC's transient 'package is being compiled' response.

    HTTP 200 with a non-zero ret.code, so it is only visible if ret.code is read.
    """
    if not resp.ok:
        return False
    try:
        ret = resp.json().get("ret") or {}
    except ValueError:
        return False
    return ret.get("code") == COMPILING_RET_CODE or "being compiled" in (ret.get("msg") or "").lower()


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
