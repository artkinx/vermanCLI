import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:verman/verman.dart' as verman;

void main() {
  group('Verman CLI Tests', () {
    late Directory tempDir;
    late String originalDir;
    late String scriptPath;
    late File pubspecFile;

    // A mock pubspec.yaml content for testing
    const initialPubspecContent = '''
name: test_app
description: A test app.
version: 1.2.3+4

environment:
  sdk: '>=3.0.0 <4.0.0'
''';

    // A mock build.gradle content for testing
    const initialBuildGradleContent = '''
apply plugin: 'com.android.library'

android {
    compileSdkVersion 33

    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0"
    }
    }
    ''';

    // A mock build.gradle using flutter variables
    const variableBuildGradleContent = '''
    plugins {
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.verman_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.verman_example"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
    ''';

    // A mock info.plist content for testing
    const initialInfoPlistContent = '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
</dict>
</plist>
''';

    // A mock info.plist using flutter variables
    const variableInfoPlistContent = '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleShortVersionString</key>
	<string>\$(FLUTTER_BUILD_NAME)</string>
	<key>CFBundleVersion</key>
	<string>\$(FLUTTER_BUILD_NUMBER)</string>
</dict>
</plist>
''';

    setUp(() {
      originalDir = Directory.current.path;
      scriptPath = p.join(originalDir, 'bin', 'verman.dart');
      tempDir = Directory.systemTemp.createTempSync('verman_test_');
      Directory.current = tempDir;
      pubspecFile = File(p.join(tempDir.path, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync(initialPubspecContent);
    });

    tearDown(() {
      Directory.current = originalDir;
      tempDir.deleteSync(recursive: true);
    });

    // This group tests the CLI by invoking the main function directly.
    // It's fast and good for happy paths where we check stdout.
    group('Direct Invocation Tests', () {
      test('`current` command should display the correct version', () async {
        final output = <String>[];
        // runZoned captures the output of `print`.
        runZoned(
          () => verman.main(['current']),
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, line) {
              output.add(line);
            },
          ),
        );

        expect(output, contains('Current version: 1.2.3+4'));
      });

      test(
        '`increment patch` command should update version and build number',
        () async {
          final output = <String>[];
          runZoned(
            () => verman.main(['increment', 'patch']),
            zoneSpecification: ZoneSpecification(
              print: (self, parent, zone, line) {
                output.add(line);
              },
            ),
          );

          // Check console output
          expect(output, contains('Success: Updated version to 1.2.4+5'));

          // Check file content
          final updatedContent = pubspecFile.readAsStringSync();
          expect(updatedContent, contains('version: 1.2.4+5'));
        },
      );
    });

    group('init', () {
      test('`init` command creates a verman.yaml file', () async {
        final configFile = File(p.join(tempDir.path, 'verman.yaml'));
        expect(configFile.existsSync(), isFalse);

        final output = <String>[];
        runZoned(
          () => verman.main(['init']),
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, line) {
              output.add(line);
            },
          ),
        );

        expect(
          output,
          contains('✅ Created verman.yaml with default configuration.'),
        );
        expect(configFile.existsSync(), isTrue);
        final content = configFile.readAsStringSync();
        expect(content, contains('# Verman configuration file.'));
        expect(content, contains('# paths:'));
      });
    });

    // This group tests the CLI by running it as a separate process.
    // This is the most accurate way to test the public interface,
    // including exit codes and stderr.
    group('Process Execution Tests', () {
      test(
        '`increment` command with missing part should show error and exit',
        () async {
          // The path to the entrypoint script.
          // Run the CLI command as a separate process.
          final result = await Process.run(
            Platform.executable, // This is 'dart'
            [scriptPath, 'increment'],
            workingDirectory: tempDir.path,
          );

          // Check for a non-zero exit code, indicating an error.
          expect(result.exitCode, isNot(0));
          // Check stderr for the expected error message.
          expect(result.stderr, contains('Error: Missing part to increment.'));
          // Ensure the file was not modified.
          expect(pubspecFile.readAsStringSync(), initialPubspecContent);
        },
      );

      test('`increment` command with invalid part should show error', () async {
        final result = await Process.run(Platform.executable, [
          scriptPath,
          'increment',
          'invalid_part',
        ], workingDirectory: tempDir.path);

        expect(result.exitCode, isNot(0));
        expect(result.stderr, contains('Error: Invalid part "invalid_part".'));
      });
    });

    void _createMockPlatformFiles({
      required String buildGradleContent,
      required String infoPlistContent,
      String androidPath = 'android/app/build.gradle',
      String iosPath = 'ios/Runner/Info.plist',
    }) {
      final androidDir = Directory(p.dirname(p.join(tempDir.path, androidPath)))
        ..createSync(recursive: true);
      File(
        p.join(tempDir.path, androidPath),
      ).writeAsStringSync(buildGradleContent);

      final iosDir = Directory(p.dirname(p.join(tempDir.path, iosPath)))
        ..createSync(recursive: true);
      File(
        p.join(tempDir.path, iosPath),
      ).writeAsStringSync(infoPlistContent);
    }

    group('check-platforms', () {
      test('reports out-of-sync for hardcoded mismatching versions', () async {
        _createMockPlatformFiles(
          buildGradleContent: initialBuildGradleContent, // 1.0+1
          infoPlistContent: initialInfoPlistContent, // 1.0+1
        );

        final result = await Process.run(Platform.executable, [
          scriptPath,
          'check-platforms',
        ], workingDirectory: tempDir.path);

        expect(result.exitCode, 0);
        expect(result.stdout, contains('❌ Out of Sync'));
        // expect(
        //   result.stderr,
        //   contains('one or more platform versions are out'),
        // );
      });

      test('reports in-sync for variable-based versions', () async {
        _createMockPlatformFiles(
          buildGradleContent: variableBuildGradleContent,
          infoPlistContent: variableInfoPlistContent,
        );

        final result = await Process.run(Platform.executable, [
          scriptPath,
          'check-platforms',
        ], workingDirectory: tempDir.path);

        expect(result.exitCode, 0);
        expect(result.stdout, contains('✅ In Sync (using Flutter variables)'));
        expect(result.stderr, isEmpty);
      });

      test('respects custom paths from verman.yaml', () async {
        // Create a config file with custom paths
        File(p.join(tempDir.path, 'verman.yaml')).writeAsStringSync('''
paths:
  android: custom/android/build.gradle
  ios: custom/ios/Info.plist
''');

        // Create platform files at the custom paths
        _createMockPlatformFiles(
          buildGradleContent: initialBuildGradleContent, // 1.0+1 -> out of sync
          infoPlistContent:
              variableInfoPlistContent, // uses variables -> in sync
          androidPath: 'custom/android/build.gradle',
          iosPath: 'custom/ios/Info.plist',
        );

        final result = await Process.run(Platform.executable, [
          scriptPath,
          'check-platforms',
        ], workingDirectory: tempDir.path);

        expect(result.exitCode, 0);
        expect(
          result.stdout,
          contains(
            'Android (custom/android/build.gradle) version: 1.0 (1) - ❌ Out of Sync',
          ),
        );
        expect(
          result.stdout,
          contains('iOS (custom/ios/Info.plist) - ✅ In Sync'),
        );
      });
    });

    group('sync', () {
      test('updates hardcoded platform files to match pubspec', () async {
        // pubspec is 1.2.3+4
        _createMockPlatformFiles(
          buildGradleContent: initialBuildGradleContent, // 1.0+1
          infoPlistContent: initialInfoPlistContent, // 1.0+1
        );

        final result = await Process.run(Platform.executable, [
          scriptPath,
          'sync',
        ], workingDirectory: tempDir.path);

        expect(result.exitCode, 0);
        expect(result.stdout, contains('Syncing version 1.2.3+4'));
        expect(result.stdout, contains('✅ Synced.'));

        // Check Android file
        final newGradleContent = File(
          p.join(tempDir.path, 'android/app/build.gradle'),
        ).readAsStringSync();
        expect(newGradleContent, contains('versionCode 4'));
        expect(newGradleContent, contains('versionName "1.2.3"'));

        // Check iOS file
        final newPlistContent = File(
          p.join(tempDir.path, 'ios/Runner/Info.plist'),
        ).readAsStringSync();
        expect(newPlistContent, contains('<string>4</string>'));
        expect(newPlistContent, contains('<string>1.2.3</string>'));
      });

      test('does not change platform files that use variables', () async {
        _createMockPlatformFiles(
          buildGradleContent: variableBuildGradleContent,
          infoPlistContent: variableInfoPlistContent,
        );

        final result = await Process.run(Platform.executable, [
          scriptPath,
          'sync',
        ], workingDirectory: tempDir.path);

        expect(result.exitCode, 0);
        expect(
          result.stdout,
          contains('✅ Already configured to use Flutter variables.'),
        );
        expect(
          File(
            p.join(tempDir.path, 'android/app/build.gradle'),
          ).readAsStringSync(),
          variableBuildGradleContent,
        );
        expect(
          File(
            p.join(tempDir.path, 'ios/Runner/Info.plist'),
          ).readAsStringSync(),
          variableInfoPlistContent,
        );
      });

      test('syncs files at custom paths from verman.yaml', () async {
        // pubspec is 1.2.3+4
        File(p.join(tempDir.path, 'verman.yaml')).writeAsStringSync('''
paths:
  android: my_app/gradle.build
  ios: my_ios_app/MyInfo.plist
''');

        _createMockPlatformFiles(
          buildGradleContent: initialBuildGradleContent, // 1.0+1
          infoPlistContent: initialInfoPlistContent, // 1.0+1
          androidPath: 'my_app/gradle.build',
          iosPath: 'my_ios_app/MyInfo.plist',
        );

        await Process.run(Platform.executable, [
          scriptPath,
          'sync',
        ], workingDirectory: tempDir.path);

        // Check Android file at custom path
        final newGradleContent = File(
          p.join(tempDir.path, 'my_app/gradle.build'),
        ).readAsStringSync();
        expect(newGradleContent, contains('versionCode 4'));
        expect(newGradleContent, contains('versionName "1.2.3"'));

        // Check iOS file at custom path
        final newPlistContent = File(
          p.join(tempDir.path, 'my_ios_app/MyInfo.plist'),
        ).readAsStringSync();
        expect(newPlistContent, contains('<string>4</string>'));
        expect(newPlistContent, contains('<string>1.2.3</string>'));
      });
    });
  });
}
