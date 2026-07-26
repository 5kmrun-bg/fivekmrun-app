#!/usr/bin/env python3
"""Tests for huawei_publish.py — run with `python3 -m unittest discover .github/scripts`.

These cover the failure reporting, which is the part of the pipeline we cannot
exercise against the real AppGallery Connect API from a test.
"""

import json
import unittest
from unittest import mock

import huawei_publish as hp


class FakeResponse:
    """The bits of requests.Response that huawei_publish reads."""

    def __init__(self, status_code, text="", reason=""):
        self.status_code = status_code
        self.text = text
        self.reason = reason

    @property
    def ok(self):
        return 200 <= self.status_code < 300

    def json(self):
        return json.loads(self.text)


class TokenAuthorityFailureTest(unittest.TestCase):
    """The real 403 seen in run 30198840817: empty body, diagnostic in the reason phrase."""

    def setUp(self):
        self.resp = FakeResponse(403, text="", reason="client token authorization fail.")

    def test_reports_the_reason_phrase(self):
        # Regression: describe() once logged only status + body, so this exact
        # response degraded to a bare "HTTP 403" and lost the only diagnostic AGC gave.
        with self.assertRaises(hp.PublishError) as caught:
            hp.check("upload-url/for-obs", self.resp)
        self.assertIn("client token authorization fail.", str(caught.exception))

    def test_points_at_the_console_prerequisites(self):
        with self.assertRaises(hp.PublishError) as caught:
            hp.check("upload-url/for-obs", self.resp)
        message = str(caught.exception)
        self.assertIn("not authorised to publish", message)
        # The message must name the actual cause: a project-scoped client. Earlier
        # wording listed three vague prerequisites and sent us hunting the role,
        # which was never wrong. Ten runs failed before the client type was checked.
        self.assertIn("project_client_id", message)
        self.assertIn("team_client_id", message)
        self.assertIn("Project = N/A", message)

    def test_401_variant_is_caught_too(self):
        resp = FakeResponse(401, text="", reason="client token auth failed")
        with self.assertRaises(hp.PublishError):
            hp.check("upload-url/for-obs", resp)


class AgcBusinessErrorTest(unittest.TestCase):
    """AGC returns HTTP 200 with a non-zero ret.code for business errors."""

    def test_non_zero_ret_code_is_a_failure(self):
        resp = FakeResponse(200, text=json.dumps({"ret": {"code": 204144660, "msg": "boom"}}))
        with self.assertRaises(hp.PublishError) as caught:
            hp.check("app-submit", resp)
        self.assertIn("204144660", str(caught.exception))

    def test_duplicate_version_is_explained_not_raw(self):
        resp = FakeResponse(
            200,
            text=json.dumps({"ret": {"code": 204144660, "msg": "the version already exists"}}),
        )
        with self.assertRaises(hp.PublishError) as caught:
            hp.check("app-file-info/update", resp)
        message = str(caught.exception)
        self.assertIn("already has this version", message)
        self.assertIn("Bump the build number", message)

    def test_zero_ret_code_passes_through(self):
        resp = FakeResponse(200, text=json.dumps({"ret": {"code": 0}, "urlInfo": {"url": "x"}}))
        self.assertEqual(hp.check("upload-url/for-obs", resp)["urlInfo"]["url"], "x")

    def test_success_without_a_ret_block_passes(self):
        resp = FakeResponse(200, text=json.dumps({"access_token": "t"}))
        self.assertEqual(hp.check("token", resp)["access_token"], "t")


class EndpointShapeTest(unittest.TestCase):
    """The AGC endpoints are easy to get subtly wrong and only fail at runtime.

    Regression: attach_file POSTed to /publish/v2/app-file-info/update, which does
    not exist and returned 404. The real endpoint is PUT /publish/v2/app-file-info.
    Auth failed on every earlier run, so this was never reached until run
    30205429816 uploaded the APK to OBS successfully and then 404'd.
    """

    OK = FakeResponse(200, text=json.dumps({"ret": {"code": 0}}), reason="OK")

    def test_attach_file_puts_to_app_file_info(self):
        with mock.patch.object(hp, "requests") as req:
            req.put.return_value = self.OK
            hp.attach_file({}, "109680919", {"url": "https://obs/x.apk?sig=1"}, "x.apk", 1, "ab", "1")

        self.assertTrue(req.put.called, "app-file-info must be a PUT")
        self.assertFalse(req.post.called, "app-file-info must not be POSTed")
        url = req.put.call_args[0][0]
        self.assertTrue(url.endswith("/publish/v2/app-file-info"), f"wrong endpoint: {url}")

    def test_attach_file_strips_the_obs_query_string(self):
        with mock.patch.object(hp, "requests") as req:
            req.put.return_value = self.OK
            hp.attach_file({}, "1", {"url": "https://obs/x.apk?sig=secret"}, "x.apk", 7, "ab", "1")

        body = req.put.call_args[1]["json"]
        self.assertEqual(body["files"][0]["fileDestUrl"], "https://obs/x.apk")

    def test_submit_posts_to_app_submit(self):
        with mock.patch.object(hp, "requests") as req:
            req.post.return_value = self.OK
            hp.submit({}, "109680919", "1", "note")

        url = req.post.call_args[0][0]
        self.assertTrue(url.endswith("/publish/v2/app-submit"), f"wrong endpoint: {url}")
        params = req.post.call_args[1]["params"]
        self.assertEqual(params["appId"], "109680919")
        self.assertEqual(params["releaseType"], "1")


class MalformedResponseTest(unittest.TestCase):
    def test_non_json_body_is_reported_legibly(self):
        resp = FakeResponse(200, text="<html>gateway</html>", reason="OK")
        with self.assertRaises(hp.PublishError) as caught:
            hp.check("token", resp)
        self.assertIn("non-JSON body", str(caught.exception))

    def test_server_error_reports_status_and_body(self):
        resp = FakeResponse(500, text="upstream exploded", reason="Internal Server Error")
        with self.assertRaises(hp.PublishError) as caught:
            hp.check("app-submit", resp)
        message = str(caught.exception)
        self.assertIn("500", message)
        self.assertIn("upstream exploded", message)

    def test_long_body_is_truncated(self):
        resp = FakeResponse(500, text="x" * 9000, reason="Internal Server Error")
        self.assertIn("[truncated]", hp.describe(resp))


if __name__ == "__main__":
    unittest.main()
