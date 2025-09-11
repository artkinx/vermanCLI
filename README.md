# Verman 🦸‍♂️

[![Pub Version](https://img.shields.io/pub/v/verman?logo=dart&label=verman)](https://pub.dev/packages/verman)
[![Lints](https://img.shields.io/badge/lints-flutter__lints-blue.svg)](https://pub.dev/packages/flutter_lints)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Your friendly neighborhood version manager for Flutter projects.**

Stop juggling versions between `pubspec.yaml`, `build.gradle`, and `Info.plist`. `Verman` automates versioning, ensuring consistency across your entire Flutter project with simple, intuitive commands.

---

## The Problem

Managing your app's version can be a repetitive and error-prone task. You update `pubspec.yaml`...

```yaml
# pubspec.yaml
version: 1.2.4+6
```

...then you have to remember to update `build.gradle`...

```gradle
// android/app/build.gradle
android {
    defaultConfig {
        versionCode 6
        versionName "1.2.4"
    }
}
```

...and also `Info.plist`.

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleShortVersionString</key>
<string>1.2.4</string>
<key>CFBundleVersion</key>
<string>6</string>
```

Forgetting a step leads to inconsistencies. `Verman` solves this.

## Features ✨

-   **View Current Version**: Instantly see your project's version.
-   **Increment with Ease**: Bump your `major`, `minor`, or `patch` version. The build number is automatically incremented.
-   **Check Consistency**: Verify that your Android and iOS versions match your `pubspec.yaml`.
-   **Sync Instantly**: Push the version from `pubspec.yaml` to your platform-specific files.
-   **Smart Detection**: Intelligently handles both hardcoded versions and modern Flutter projects that use variables like `flutter.versionCode` and `$(FLUTTER_BUILD_NAME)`.

## Installation

Activate `verman` globally from your terminal.

```sh
# From pub.dev
dart pub global activate verman
```

## Usage

Run `verman` commands from the root of your Flutter project.

### `verman current`

Displays the current version from `pubspec.yaml`.

```sh
$ verman current
Current version: 1.2.3+4
```

### `verman increment <part>`

Increments the version. `part` can be `major`, `minor`, or `patch`. The build number is always incremented.

```sh
$ verman increment patch
Success: Updated version to 1.2.4+5
```

### `verman check-platforms`

Checks for version consistency across `pubspec.yaml`, Android, and iOS.

```sh
$ verman check-platforms
Checking platform files against pubspec version: 1.2.3+4...
Android (android/app/build.gradle) version: 1.2.0 (3) - ❌ Out of Sync
iOS (ios/Runner/Info.plist) - ✅ In Sync (using Flutter variables)
```

### `verman sync`

Updates `build.gradle` and `Info.plist` to match the version in `pubspec.yaml`.

```sh
$ verman sync
Syncing version 1.2.3+4 to platforms...
Android (android/app/build.gradle) - ✅ Synced.
iOS (ios/Runner/Info.plist) - ✅ Already configured to use Flutter variables.
```

## Contributors ✨

A big thank you to all the contributors who have helped make this project better!


<table>
  <tr>
    <td align="center"><a href="https://github.com/artkinx"><img src="https://avatars.githubusercontent.com/u/69529643?s=400&u=4b3478913386ab2e0a9d4cf8e843a9eb27a66b02&v=4" width="100px;" alt=""/><br /><sub><b>Akinwande Adunbi</b></sub></a></td>
  </tr>
</table>

## License

This project is licensed under the MIT License. See the LICENSE file for details.