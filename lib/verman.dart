import 'dart:io';
// ignore: unused_import
import 'package:path/path.dart' as p;

import 'core/services/file_service.dart';

// Regular expression to find and capture the version string (e.g., 1.0.0+1)
final RegExp versionPattern = RegExp(r'version:\s*(\d+\.\d+\.\d+)(?:\+(\d+))?');

/// Gets the version name and build number from the pubspec content.
/// @param {String} content The pubspec file content.
/// @returns {{versionName: String, buildNumber: String?}} The version data, or null if not found.
Map<String, String?>? getVersion(String content) {
  final match = versionPattern.firstMatch(content);
  if (match != null) {
    return {'versionName': match.group(1), 'buildNumber': match.group(2)};
  }
  return null;
}

/// Updates the version in the pubspec.yaml file.
/// @param {String} newVersionName The new version name (e.g., "1.0.1").
/// @param {String?} newBuildNumber The new build number, or null to keep existing.
void updateVersion(String newVersionName, String? newBuildNumber) {
  var pubspecContent = FileService.getPubspecContent();
  if (pubspecContent == null) return;

  final newVersionString =
      'version: $newVersionName${newBuildNumber != null ? '+$newBuildNumber' : ''}';
  final updatedContent = pubspecContent.content.replaceFirst(
    versionPattern,
    newVersionString,
  );

  FileService.writePubspecContent(
    updatedContent,
    newVersionName,
    newBuildNumber,
  );
}

/// The main entry point for the CLI tool.
/// @param {List&lt;String&gt;} arguments The command line arguments.
void main(List<String> arguments) {
  if (arguments.isEmpty || arguments.first == 'help') {
    print('''
Available commands for Flutter projects:
  current               - Displays the current version from pubspec.yaml.
  increment [part]      - Increments the version by major, minor, or patch.
                          Example: increment patch
  build                 - Simulates running 'flutter pub run build_runner build' and increments the build number.
  sync                  - Syncs the pubspec.yaml version to platform-specific files.
  check-platforms       - Verifies that platform-specific files reference the correct version.
    ''');
    return;
  }

  if (arguments.contains('help') || arguments.contains('-h')) {
    if (arguments.first == 'current') {
      print('''
          Displays the current version from pubspec.yaml.
          Usage: dart run verman current
          Example: "Current version: 1.0.0+1"
        ''');
    }

    if (arguments.first == 'increment') {
      print('''
          Increments the version by major, minor, or patch.
          Usage: dart run verman increment [part]

          major: Increments the major version.
          minor: Increments the minor version.
          patch: Increments the patch version.

          Example: "dart run verman increment patch"
          ''');
    }

    if (arguments.first == 'build') {
      print('''
          Simulates running 'flutter pub run build_runner build' and increments the build number.
          Usage: dart run verman build
          Example: "Running 'flutter pub run build_runner build'...
          Successfully generated files and updated build number to 2."
        ''');
    }

    if (arguments.first == 'check-platforms') {
      print('''
          Compares the pubspec.yaml version against Android and iOS version files.
          Usage: dart run verman check-platforms
          Example output:
          Checking platform files against pubspec version: 1.0.0+1...
          Android (android/app/build.gradle) version: 1.0.0 (1) - ✅ In Sync
          iOS (ios/Runner/Info.plist) version: 1.0.0 (1) - ✅ In Sync
        ''');
    }

    if (arguments.first == 'sync') {
      print('''
          Updates Android and iOS version files to match pubspec.yaml.
          Usage: dart run verman sync
          Note: This only works for hardcoded versions, not Flutter variables like `\$(FLUTTER_BUILD_NAME)`.
        ''');
    }

    return;
  }

  final command = arguments.first;
  final args = arguments.skip(1).toList();

  switch (command) {
    case 'current':
      final content = FileService.getPubspecContent();
      if (content != null) {
        final versionData = getVersion(content.content);
        if (versionData != null) {
          if (versionData['buildNumber'] != null) {
            print(
              'Current version: ${versionData['versionName']}+${versionData['buildNumber']}',
            );
          } else {
            print('Current version: ${versionData['versionName']}');
          }
        } else {
          stderr.writeln('Error: Could not find version in pubspec.yaml.');
        }
      }
      break;

    case 'increment':
      if (args.isEmpty) {
        stderr.writeln(
          'Error: Missing part to increment. Use "major", "minor", or "patch".',
        );
        exit(1);
      }
      final partToIncrement = args[0];
      final parts = ['major', 'minor', 'patch'];
      if (!parts.contains(partToIncrement)) {
        stderr.writeln(
          'Error: Invalid part "$partToIncrement". Use "major", "minor", or "patch".',
        );
        exit(1);
      }

      final content = FileService.getPubspecContent();
      if (content == null) {
        exit(1);
      }

      final currentVersion = getVersion(content.content);
      if (currentVersion == null) {
        stderr.writeln('Error: Could not find a valid version to increment.');
        return;
      }

      var newVersionParts = currentVersion['versionName']!
          .split('.')
          .map(int.parse)
          .toList();
      if (partToIncrement == 'major') {
        newVersionParts[0]++;
        newVersionParts[1] = 0;
        newVersionParts[2] = 0;
      } else if (partToIncrement == 'minor') {
        newVersionParts[1]++;
        newVersionParts[2] = 0;
      } else if (partToIncrement == 'patch') {
        newVersionParts[2]++;
      }

      final newVersionName = newVersionParts.join('.');
      final newBuildNumber =
          (int.tryParse(currentVersion['buildNumber'] ?? '0') ?? 0) + 1;

      updateVersion(newVersionName, newBuildNumber.toString());
      break;

    case 'build':
      final content = FileService.getPubspecContent();
      if (content == null) {
        exit(1);
      }

      final currentBuild = getVersion(content.content);
      if (currentBuild == null) {
        stderr.writeln('Error: Could not find a valid version to increment.');
        return;
      }

      final newBuildNumber =
          (int.tryParse(currentBuild['buildNumber'] ?? '0') ?? 0) + 1;

      print('Running \'flutter pub run build_runner build\'...');
      updateVersion(currentBuild['versionName']!, newBuildNumber.toString());
      print(
        'Successfully generated files and updated build number to $newBuildNumber.',
      );
      break;

    case 'check-platforms':
      final pubspecContent = FileService.getPubspecContent();
      if (pubspecContent == null) {
        exit(1);
      }

      final pubspecVersion = getVersion(pubspecContent.content);
      if (pubspecVersion == null) {
        stderr.writeln(
          'Error: Could not find version in pubspec.yaml to check.',
        );
        return;
      }

      print(
        'Checking platform files against pubspec version: ${pubspecVersion['versionName']}+${pubspecVersion['buildNumber']}...',
      );
      var allInSync = true;

      // Check Android
      final androidVersion = FileService.getAndroidVersion();
      if (androidVersion == null) {
        print(
          'Android (android/app/build.gradle) - ⚠️ Not found or could not read.',
        );
        allInSync = false;
      } else if (androidVersion.isEmpty) {
        print(
          'Android (android/app/build.gradle) - ⚠️ Could not parse version.',
        );
        allInSync = false;
      } else {
        final isVariable =
            androidVersion['versionName'] == 'flutter.versionName';
        if (isVariable) {
          print(
            'Android (android/app/build.gradle) - ✅ In Sync (using Flutter variables)',
          );
        } else {
          final isNameMatch =
              androidVersion['versionName'] == pubspecVersion['versionName'];
          final isCodeMatch =
              androidVersion['buildNumber'] == pubspecVersion['buildNumber'];
          final status = isNameMatch && isCodeMatch
              ? '✅ In Sync'
              : '❌ Out of Sync';
          print(
            'Android (android/app/build.gradle) version: ${androidVersion['versionName']} (${androidVersion['buildNumber']}) - $status',
          );
          if (!isNameMatch || !isCodeMatch) allInSync = false;
        }
      }

      // Check iOS
      final iosVersion = FileService.getIosVersion();
      if (iosVersion == null) {
        print('iOS (ios/Runner/Info.plist) - ⚠️ Not found or could not read.');
        allInSync = false;
      } else if (iosVersion.isEmpty) {
        print('iOS (ios/Runner/Info.plist) - ⚠️ Could not parse version.');
        allInSync = false;
      } else {
        final isVariable =
            iosVersion['versionName'] == r'$(FLUTTER_BUILD_NAME)';
        if (isVariable) {
          print(
            'iOS (ios/Runner/Info.plist) - ✅ In Sync (using Flutter variables)',
          );
        } else {
          final isNameMatch =
              iosVersion['versionName'] == pubspecVersion['versionName'];
          final isCodeMatch =
              iosVersion['buildNumber'] == pubspecVersion['buildNumber'];
          final status = isNameMatch && isCodeMatch
              ? '✅ In Sync'
              : '❌ Out of Sync';
          print(
            'iOS (ios/Runner/Info.plist) version: ${iosVersion['versionName']} (${iosVersion['buildNumber']}) - $status',
          );
          if (!isNameMatch || !isCodeMatch) allInSync = false;
        }
      }

      print(''); // Newline for spacing
      if (allInSync) {
        print('All platform versions are in sync with pubspec.yaml.');
      } else {
        stderr.writeln(
          '''Warning: One or more platform versions are out of sync.
          
          run 'dart run verman sync' to sync.
          ''',
        );
      }
      break;

    case 'sync':
      final pubspecContent = FileService.getPubspecContent();
      if (pubspecContent == null) {
        exit(1);
      }

      final pubspecVersion = getVersion(pubspecContent.content);
      if (pubspecVersion == null || pubspecVersion['buildNumber'] == null) {
        stderr.writeln(
          'Error: pubspec.yaml must contain a version and build number (e.g., 1.2.3+1) to sync.',
        );
        exit(1);
      }

      final versionName = pubspecVersion['versionName']!;
      final buildNumber = pubspecVersion['buildNumber']!;

      print('Syncing version $versionName+$buildNumber to platforms...');

      // Check and sync Android
      final androidVersion = FileService.getAndroidVersion();
      if (androidVersion != null &&
          androidVersion['versionName'] == 'flutter.versionName') {
        print(
          'Android (android/app/build.gradle) - ✅ Already configured to use Flutter variables.',
        );
      } else {
        final androidUpdated = FileService.updateAndroidVersion(
          versionName,
          buildNumber,
        );

        print(
          'Android (android/app/build.gradle) - ${androidUpdated ? '✅ Synced.' : '⚠️ Not found or no changes made.'}',
        );
      }

      // Check and sync iOS
      final iosVersion = FileService.getIosVersion();
      if (iosVersion != null &&
          iosVersion['versionName'] == r'$(FLUTTER_BUILD_NAME)') {
        print(
          'iOS (ios/Runner/Info.plist) - ✅ Already configured to use Flutter variables.',
        );
      } else {
        final iosUpdated = FileService.updateIosVersion(
          versionName,
          buildNumber,
        );

        if (!iosUpdated) {
          var isIosInitialized = FileService.initializeIosVersion();

          if (isIosInitialized) {
            print('iOS (ios/Runner/Info.plist) - ✅ Initialized.');
          } else {
            print('iOS (ios/Runner/Info.plist) - ⚠️ Could not initialize.');
          }
        } else {
          print(
            'iOS (ios/Runner/Info.plist) - ${iosUpdated ? '✅ Synced.' : '⚠️ Not found or no changes made.'}',
          );
        }
      }

      print('\nSync complete.');
      break;

    default:
      stderr.writeln(
        '\'$command\' is not a recognized command. Type "verman help" for a list of commands.',
      );
      exit(1);
  }
}
