# 5kmrun.bg 

The official mobile application for https://5kmrun.bg/ written in Flutter.

## Prerequisites

- Install [Flutter](https://docs.flutter.dev/get-started/install). Make sure `flutter doctor` does not report any issues (this will require installing Xcode, Android Studio and a bunch of other dependencies).

- Run `flutter pub get` to install all dependencies.

- Create `fivekmrun_app_flutter\lib\private\secretes.dart` file with the following content:

```dart
const stravaSecret = "<strava_secret>";
const stravaClientId = "<strava_app_id>";
const googleMapsKey = "<google_maps_key>";
```

## Running the app

Use flutter cli to run the app on a simulator or a real device:

`flutter run`

