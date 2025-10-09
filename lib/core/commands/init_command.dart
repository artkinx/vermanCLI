import 'dart:io';
import 'package:path/path.dart' as p;

import 'base_command.dart';

class InitCommand extends BaseCommand {
  InitCommand(super.args);

  /// Initializes the project by setting up the config file for the verman conftrol
  /// writes into a new file [verman.yaml] by default
  @override
  Future<void> run() async {


    File? configFile;

    if (config.configFilePath.isNotEmpty) {
      configFile = File(config.configFilePath);
    } else {
      configFile = File(p.join(Directory.current.path, 'verman.yaml'));
    }

    if (!configFile.existsSync()) {
      // Default configuration
      const defaultConfig = '''
# Verman configuration file.
# For more information, see the Verman documentation on GitHub.
#
# Use this file to override default behaviors.

# You can specify custom paths to your platform-specific version files.
# If a path is not provided, Verman will search for default files
# (e.g., `android/app/build.gradle` or `android/app/build.gradle.kts`).
#
# verman:
#   android: path/to/your/build.gradle
#   ios: path/to/your/Info.plist
''';
      try {
        configFile.writeAsStringSync(
          config.configFilePath.isEmpty ? defaultConfig : config.configFilePath,
        );
      } catch (e) {
        print('An error occurred while creating your config file.');
        exit(1);
      }
      print('✅ Created verman.yaml with default configuration.');
    } else {
      print('verman.yaml already exists.');
    }
  }
}
