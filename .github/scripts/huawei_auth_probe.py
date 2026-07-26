#!/usr/bin/env python3
"""Diagnose Huawei AppGallery Connect credentials without building the app.

huawei_publish.py can only tell you that the first publishing call was refused.
This probe tells you *why*, by calling several endpoints of increasing privilege
and reporting each independently instead of stopping at the first failure. It
never raises on an API error — one run gives the whole picture.

Read the result like this:

  token fails                  -> the client_id/secret pair is wrong or revoked.
  token OK, every call 403     -> the AppGallery Connect API is not enabled for
                                  the account, or the client is not team/project
                                  level. Not an app-scope problem: a client that
                                  simply cannot see this app usually still gets a
                                  reply on the account-wide appid-list call.
  appid-list OK, app calls 403 -> the client works, but is not scoped to this
                                  appId. Compare the appId it lists for the
                                  package name against HUAWEI_APP_ID.
  appid-list lists a DIFFERENT appId than HUAWEI_APP_ID
                               -> HUAWEI_APP_ID is simply wrong. That secret was
                                  set during the abandoned service-account era
                                  and has never been re-verified.

Environment: HUAWEI_CLIENT_ID, HUAWEI_CLIENT_SECRET, HUAWEI_APP_ID
Optional:    HUAWEI_PACKAGE_NAME  - to resolve package name -> appId
             HUAWEI_REVEAL_IDS    - "true" prints partial ID values (see below)
"""

import os
import sys

import requests

DOMAIN = "https://connect-api.cloud.huawei.com/api"


def describe(resp):
    body = resp.text
    if len(body) > 2000:
        body = body[:2000] + "... [truncated]"
    return f"HTTP {resp.status_code} {resp.reason or ''} {body}".rstrip()


def partial(value):
    """A fingerprint of a secret: enough to compare against the console, not enough to use.

    GitHub only masks exact secret matches, so a substring would print in full.
    That is why this is gated behind HUAWEI_REVEAL_IDS and off by default.
    """
    if not value:
        return "(empty)"
    if len(value) <= 8:
        return f"(len {len(value)}, too short to show safely)"
    return f"{value[:4]}...{value[-4:]} (len {len(value)})"


def report_ids(client_id, app_id, package_name):
    print("=== Identifiers ===")
    print(f"package name : {package_name or '(not provided)'}")
    if os.environ.get("HUAWEI_REVEAL_IDS", "").lower() == "true":
        print(f"HUAWEI_CLIENT_ID : {partial(client_id)}")
        print(f"HUAWEI_APP_ID    : {partial(app_id)}")
    else:
        print(f"HUAWEI_CLIENT_ID : set, {len(client_id)} chars (re-run with reveal_ids to fingerprint)")
        print(f"HUAWEI_APP_ID    : set, {len(app_id)} chars (re-run with reveal_ids to fingerprint)")
    print()


def get_token(client_id, client_secret):
    print("=== 1. OAuth token ===")
    try:
        resp = requests.post(
            f"{DOMAIN}/oauth2/v1/token",
            json={
                "client_id": client_id,
                "client_secret": client_secret,
                "grant_type": "client_credentials",
            },
            timeout=60,
        )
    except requests.RequestException as exc:
        print(f"token: network error: {exc}\n")
        return None

    print(f"token: {describe(resp)}")
    if not resp.ok:
        print("-> The client_id/client_secret pair itself is rejected. Everything below will fail.\n")
        return None
    try:
        token = resp.json().get("access_token")
    except ValueError:
        print("-> Token endpoint returned a non-JSON body.\n")
        return None
    if not token:
        print("-> Token endpoint returned no access_token.\n")
        return None
    print("-> Token issued. The credentials are valid; anything below is authorisation, not auth.\n")
    return token


def probe(label, method, path, headers, params, explain):
    print(f"=== {label} ===")
    print(f"{method} {path}  params={ {k: v for k, v in params.items()} }")
    try:
        resp = requests.request(
            method, f"{DOMAIN}{path}", headers=headers, params=params, timeout=60
        )
    except requests.RequestException as exc:
        print(f"network error: {exc}\n")
        return None

    print(describe(resp))
    print(f"-> {explain}\n")
    if resp.ok:
        try:
            return resp.json()
        except ValueError:
            return None
    return None


def main():
    try:
        client_id = os.environ["HUAWEI_CLIENT_ID"]
        client_secret = os.environ["HUAWEI_CLIENT_SECRET"]
        app_id = os.environ["HUAWEI_APP_ID"]
    except KeyError as exc:
        print(f"Missing required environment variable: {exc}", file=sys.stderr)
        return 1

    package_name = os.environ.get("HUAWEI_PACKAGE_NAME", "").strip()

    report_ids(client_id, app_id, package_name)

    token = get_token(client_id, client_secret)
    if not token:
        return 1

    headers = {"Authorization": f"Bearer {token}", "client_id": client_id}

    # Account-wide, no appId. Isolates "client has no publishing access at all"
    # from "client cannot see this particular app".
    if package_name:
        listed = probe(
            "2. Resolve package name -> appId (account-wide, no appId involved)",
            "GET",
            "/publish/v2/appid-list",
            headers,
            {"packageName": package_name},
            "If this succeeds, the client can talk to the publishing API and the "
            "problem is app scope. If this 403s too, the API is not enabled for the "
            "account or the client is not team/project level.",
        )
        if listed:
            print(f"appid-list payload: {listed}")
            print(
                "-> Compare the appId above against HUAWEI_APP_ID. A mismatch is the "
                "whole bug: that secret predates the current API client and has never "
                "been re-verified.\n"
            )

    # App-scoped read. Cheaper and safer than the upload-url call.
    probe(
        "3. Read app info (app-scoped, read-only)",
        "GET",
        "/publish/v2/app-info",
        headers,
        {"appId": app_id, "releaseType": 1},
        "Succeeds if the client is scoped to this appId. A 403 here with a working "
        "step 2 means the client cannot see this app.",
    )

    # The exact call the real pipeline dies on.
    probe(
        "4. Request an upload URL (the call the pipeline fails on)",
        "GET",
        "/publish/v2/upload-url/for-obs",
        headers,
        {
            "appId": app_id,
            "fileName": "probe.apk",
            "sha256": "0" * 64,
            "contentLength": 1,
            "releaseType": 1,
        },
        "This is the publishing permission itself. If steps 2 and 3 pass and this "
        "fails, the client's role lacks app-release rights.",
    )

    print("=== Done ===")
    print("This probe never fails the job — read the statuses above.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
