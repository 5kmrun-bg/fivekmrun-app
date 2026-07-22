---
description: Prepare and ship a new release — version bump, tag, store notes, GitHub Release, deploy workflows
---

Prepare a new release of the app. Follow these steps in order.

1. **Determine version bump** — If the user did not specify major/minor/patch, inspect the commits since the last tag (`git log <last-tag>..HEAD --oneline`) and ask: "Should this be a minor or patch bump?" (ask about major only if there are breaking changes). Wait for the answer before proceeding.

2. **Bump the version in `pubspec.yaml`** — Current format is `MAJOR.MINOR.PATCH+BUILD`. Increment the appropriate semver segment and increment the build number by 1. Edit `pubspec.yaml` directly.

3. **Commit and push the version bump** — Commit only `pubspec.yaml` with message `chore: bump version to X.Y.Z+N`, then push directly to `master`.

4. **Collect the changelog** — Run `git log <last-tag>..HEAD --pretty=format:"- %s"` to list all commits since the previous tag. Clean up the list (remove merge commits, CI noise). This becomes the tag description.

5. **Create and push the release tag** — Create an annotated tag named `vX.Y.Z` on `master` with the changelog as the tag message, then push it:
   ```
   git tag -a vX.Y.Z -m "$(changelog)"
   git push origin vX.Y.Z
   ```

6. **Generate store release notes** — Translate the changelog into user-facing language (no technical jargon, bullet points, max 500 characters each). Write two files:
   - `whatsnew/whatsnew-bg` — Bulgarian
   - `whatsnew/whatsnew-en-GB` — English

   Format (plain text, no headings, bullet character `•`):
   ```
   • User-facing change 1
   • User-facing change 2
   ```

   Commit both files directly to `master` with message `chore: add release notes for vX.Y.Z` and push.

7. **Create a GitHub Release** — Create a GitHub Release from the tag using the English release notes as the body:
   ```
   gh release create vX.Y.Z --repo 5kmrun-bg/fivekmrun-app --title "vX.Y.Z" --notes "..."
   ```

8. **Trigger the deployment workflows** — Both workflows use `workflow_dispatch`. Trigger them via the GitHub CLI:
   ```
   gh workflow run upload-appstore.yml --repo 5kmrun-bg/fivekmrun-app
   gh workflow run upload-playstore.yml --repo 5kmrun-bg/fivekmrun-app
   ```

   After triggering, report these links so the user can monitor and review everything directly:
   - **GitHub Release:** `https://github.com/5kmrun-bg/fivekmrun-app/releases/tag/vX.Y.Z`
   - **App Store Connect:** `https://appstoreconnect.apple.com/apps/1489549617/testflight/ios`
   - **Google Play Console:** `https://play.google.com/console/developers/app/bg.fivekmpark.fivekmrun/tracks/production`
   - **iOS workflow run:** (URL returned by `gh run list`)

Note that steps 3, 5, 6 and 8 push to `master` and publish to the app stores. These are the intended behaviour of this command — the general "always open a PR" rule in `CLAUDE.md` does not apply here.
