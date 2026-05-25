# 5kmrun.bg — Mobile App

[![CI](https://github.com/5kmrun-bg/fivekmrun-app/actions/workflows/continuous-integration-build.yml/badge.svg)](https://github.com/5kmrun-bg/fivekmrun-app/actions/workflows/continuous-integration-build.yml)
[![App Store](https://github.com/5kmrun-bg/fivekmrun-app/actions/workflows/upload-appstore.yml/badge.svg)](https://github.com/5kmrun-bg/fivekmrun-app/actions/workflows/upload-appstore.yml)
[![Play Store](https://github.com/5kmrun-bg/fivekmrun-app/actions/workflows/upload-playstore.yml/badge.svg)](https://github.com/5kmrun-bg/fivekmrun-app/actions/workflows/upload-playstore.yml)

The official mobile application for **[5kmrun.bg](https://5kmrun.bg)** — Bulgaria's free weekly 5 km run community. Built with Flutter, targeting Android and iOS.

---

## Download

[<img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" height="48" alt="Download on the App Store">](https://apps.apple.com/bg/app/5kmrun-bg/id1299888204)
&nbsp;&nbsp;
[<img src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg" height="48" alt="Get it on Google Play">](https://play.google.com/store/apps/details?id=bg.fivekmpark.fivekmrun&hl=bg)

---

## What is 5kmrun.bg?

5kmrun.bg organises free, timed 5 km runs every Saturday in parks across Bulgaria. The app lets participants:

- **Log official Saturday runs** by scanning the event barcode at the finish line
- **Add Strava selfie-runs** — any GPS-tracked 5 km outdoor run recorded in Strava
- **Track progress** with weekly charts, personal bests, and run history
- **Browse events** — upcoming and past run locations
- **View any profile** in read-only mode using *Login with ID* (try IDs: `13731`, `2`, `18880`)

---

## Repository layout

| Path | Contents |
|---|---|
| [`fivekmrun_app_flutter/`](fivekmrun_app_flutter/) | Flutter app source — see its [README](fivekmrun_app_flutter/README.md) for setup instructions |
| [`website-resources/`](website-resources/) | Static assets related to the web presence |

---

## Contributing

PRs are very welcome! A few guidelines:

- **Open an issue first** for any significant feature so we can align on direction
- **Test on both platforms** (iOS and Android) before opening a PR — reach out on Discord if you need help with a platform you don't have access to
- **Aim for parity** between iOS and Android; platform-specific exceptions are acceptable where no alternative exists

See the [Flutter app README](fivekmrun_app_flutter/README.md) for local setup, secrets configuration, and build commands.

## Community

Questions, ideas, support → **[Discord](https://discord.gg/sNDuvPKsWm)**

---

## Contributors

![Contributors](./CONTRIBUTORS.svg)
