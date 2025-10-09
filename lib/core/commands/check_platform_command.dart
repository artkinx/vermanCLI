import 'dart:io';

import '../services/command_service.dart';
import 'base_command.dart';

class CheckPlatformCommand extends BaseCommand {
  CheckPlatformCommand(super.args);

  /// check to confirm if the ios and android platforms are correctly setup
  /// to either reference the version info from the flutter object or manually set
  @override
  Future<void> run() async {
    final content = await BaseCommand.getPubspecContent;
    if (content == null) {
      exit(1);
    }


    final pubspecVersion = CommandService.getVersion(content.content);
    if (pubspecVersion == null) {
      stderr.writeln('Error: Could not find version in pubspec.yaml to check.');
      return;
    }

    print(
      'Checking platform files against pubspec version: ${pubspecVersion['versionName']}+${pubspecVersion['buildNumber']}...',
    );
    var allInSync = true;

    // Check Android
    final androidVersion = CommandService.getAndroidVersion(
      config.androidGradlePath,
    );
    if (androidVersion == null) {
      print(
        'Android (android/app/build.gradle) - ⚠️ Not found or could not read.',
      );
      allInSync = false;
    } else if (androidVersion.isEmpty) {
      print('Android (android/app/build.gradle) - ⚠️ Could not parse version.');
      allInSync = false;
    } else {
      final isVariable = androidVersion['versionName'] == 'flutter.versionName';
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

      // Check iOS
      final iosVersion = CommandService.getIosVersion(config.iosInfoPlistPath);
      if (iosVersion == null) {
        print(
          'iOS (${config.iosInfoPlistPath}) - ⚠️ Not found or could not read.',
        );
        allInSync = false;
      } else if (iosVersion.isEmpty) {
        print('iOS (${config.iosInfoPlistPath}) - ⚠️ Could not parse version.');
        allInSync = false;
      } else {
        final isVariable =
            iosVersion['versionName'] == r'$(FLUTTER_BUILD_NAME)';
        if (isVariable) {
          print(
            'iOS (${config.iosInfoPlistPath}) - ✅ In Sync (using Flutter variables)',
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
    }
  }
}
