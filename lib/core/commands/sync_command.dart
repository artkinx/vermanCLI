import 'dart:io';

import 'package:verman/core/services/command_service.dart';

import '../services/file_service.dart';
import 'base_command.dart';

class SyncCommand extends BaseCommand {
  SyncCommand(super.args);

  @override
  Future<void> run() async {
    final pubspecContent = FileService.getPubspecContent();
    if (pubspecContent == null) {
      exit(1);
    }

    final pubspecVersion = CommandService.getVersion(pubspecContent.content);
    if (pubspecVersion == null || pubspecVersion['buildNumber'] == null) {
      stderr.writeln(
        'Error: pubspec.yaml must contain a version and build number (e.g., 1.2.3+1) to sync.',
      );
      exit(1);
    }

    final versionName = pubspecVersion['versionName']!;
    final buildNumber = pubspecVersion['buildNumber']!;

    print('Syncing version $versionName+$buildNumber to platforms...');
    
    // Sync Android and iOS
    _syncAndroid(versionName: versionName, buildNumber: buildNumber);
    _syncIos(versionName: versionName, buildNumber: buildNumber);

    print('\nSync complete.');
  }

  void _syncAndroid({
    required String versionName,
    required String buildNumber,
  }) {
    // Check and sync Android
    final androidVersion = CommandService.getAndroidVersion(
      config.androidGradlePath,
    );
    if (androidVersion != null &&
        androidVersion['versionName'] == 'flutter.versionName') {
      print(
        'Android (android/app/build.gradle) - ✅ Already configured to use Flutter variables.',
      );
    } else {
      final androidUpdated = CommandService.updateAndroidVersion(
        versionName,
        buildNumber,
      );

      print(
        'Android (android/app/build.gradle) - ${androidUpdated ? '✅ Synced.' : '⚠️ Not found or no changes made.'}',
      );
    }
  }

  void _syncIos({required String versionName, required String buildNumber}) {
    // Check and sync iOS
    final iosVersion = CommandService.getIosVersion(config.iosInfoPlistPath);
    if (iosVersion != null &&
        iosVersion['versionName'] == r'$(FLUTTER_BUILD_NAME)') {
      print(
        'iOS (ios/Runner/Info.plist) - ✅ Already configured to use Flutter variables.',
      );
    } else {
      final iosUpdated = FileService.updateIosVersion(versionName, buildNumber);

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
  }
}
