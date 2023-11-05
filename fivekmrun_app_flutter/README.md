# 5kmrun.bg 

The official mobile application for https://5kmrun.bg/ written in Flutter.

## Contributors

![Contributors](../CONTRIBUTORS.svg)

## About the app
The application works with two types of run that happen as part of the 5kmrun.bg organization: 

 - official runs which happens every Saturday in six park around the country, in order to add such runs to your profile - you need to physically participate in those events
 - selfie runs which can be added at any time through the integration with Strava. You have to record 5km long run with GPS track (outdoors only) in your profile and then pick that run from the 5kmrun.bg application
 - the app provides weekly charts, graphs, future, and past events and other useful information around 5kmrun.bg
 - for test purposes, if you don't have account with enough data - you can open every other user account in read-only mode using the "Login with id" functionality. Some ids you can test with: 13731, 2, 18880, 67 (empty profile) 


## Prerequisites

- Install [Flutter](https://docs.flutter.dev/get-started/install). Make sure `flutter doctor` does not report any issues (this will require installing Xcode, Android Studio and a bunch of other dependencies).

- Run `flutter pub get` to install all dependencies.

- Create `fivekmrun_app_flutter\lib\private\secrets.dart` file with the following content:

```dart
const stravaSecret = "<strava_secret>";
const stravaClientId = "<strava_app_id>";
const googleMapsKey = "<google_maps_key>";
```
- To get strava secret and clientid, navigate to [developers.strava.com](https://developers.strava.com), click on "Create and Manage your app", Login, find the needed details in "My API application. N.B: "Authorization callback domain" should be set to `redirect`.

- To get googlemaps key, open [cloud.google.com/gcp](https://cloud.google.com/gcp), go to console and search for the service

## Running the app

Use flutter cli to run the app on a simulator or a real device:

`flutter run`

## Production Build Commands
- Android: `flutter build appbundle --release --no-shrink`
- iOS: `flutter build ios --release`

## Contribution Guidelines
- PRs are most welcome!
- We aim to have 100% parity between iOS and Android applications. Exceptions are acceptable for OS specific functionalities that doesn't have alternatives or have changed in the behavior. If you don't have access to macos and ios devices - reach out to a team member to assist you with testing and making sure the app works as expected.
- Before starting a major improvement - open an issue to get some feedback on how your idea fits in the needs of the organization.
- Changes should be tested on both platforms when opening a PR.

## Community

To get support and ask questions: find us in [Discord](https://discord.gg/n79eCAzWev)

