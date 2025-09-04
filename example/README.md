# Verman Example: A Hands-On Tour 🚀

This directory contains a sample Flutter project structure to demonstrate the capabilities of the `verman` CLI tool.

This example is set up to showcase a common real-world scenario: a project with one platform (iOS) using an out-of-sync, hardcoded version, and another (Android) correctly using modern Flutter variables.

For full documentation, please see the main `README.md` in the root of this repository.

---

## Step 1: Check for Inconsistencies

First, let's see the current state of the project. Our `pubspec.yaml` has version `0.1.0+1`.

Run the `check-platforms` command to see how our Android and iOS versions compare.

```sh
# Make sure you are in the 'example' directory
dart run verman check-platforms
```

**Expected Output:**
```
Checking platform files against pubspec version: 0.1.0+1...
Android (android/app/build.gradle.kts) - ✅ In Sync (using Flutter variables)
iOS (ios/Runner/Info.plist) version: 0.0.9 (9) - ❌ Out of Sync

Warning: One or more platform versions are out of sync.
```
`Verman` correctly identifies that the hardcoded iOS version is wrong, but recognizes that the Android version is fine because it uses variables.

## Step 2: Sync Everything

Now, let's fix the inconsistency with the `sync` command.

```sh
dart run verman sync
```

**Expected Output:**
```
Syncing version 0.1.0+1 to platforms...
Android (android/app/build.gradle.kts) - ✅ Already configured to use Flutter variables.
iOS (ios/Runner/Info.plist) - ✅ Synced.

Sync complete.
```
`Verman` intelligently updates the hardcoded iOS file and skips the Android file. Now, if you run `check-platforms` again, everything will be in sync!

## Step 3: Prepare for a New Release

Let's bump the patch version for our next release.

```sh
dart run verman increment patch
```

**Expected Output:**
```
Success: Updated version to 0.1.1+2
```
This updates `pubspec.yaml`. Now, if you run `check-platforms` again, you'll see that the hardcoded iOS version is out of sync once more. Just run `dart run verman sync` to fix it instantly!

## Resetting the Example

To reset all changes made during this tour, run the following command from this directory:
   ```sh
   git checkout -- .
   ```