import 'dart:io';
import 'package:path/path.dart' as p;

import 'base_command.dart';

class InitCommand extends BaseCommand {
  InitCommand(super.args);

  @override
  Future<void> run() async {
    final configFile = File(p.join(Directory.current.path, 'verman.yaml'));
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
# paths:
#   android: path/to/your/build.gradle
#   ios: path/to/your/Info.plist
''';
      configFile.writeAsStringSync(defaultConfig);
      print('✅ Created verman.yaml with default configuration.');
    } else {
      print('verman.yaml already exists.');
    }
  }
}
