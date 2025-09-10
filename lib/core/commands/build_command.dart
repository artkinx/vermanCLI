import 'dart:io';

import 'package:verman/core/services/command_service.dart';

import 'base_command.dart';

class BuildCommand extends BaseCommand {
  BuildCommand(super.args);

  @override
  Future<void> run() async {
    final content = await BaseCommand.getPubspecContent;
    if (content == null) {
      exit(1);
    }

    final currentBuild = CommandService.getVersion(content.content);
    if (currentBuild == null) {
      stderr.writeln('Error: Could not find a valid version to increment.');
      return;
    }

    final newBuildNumber =
        (int.tryParse(currentBuild['buildNumber'] ?? '0') ?? 0) + 1;

    print('Running \'flutter pub run build_runner build\'...');
    CommandService.updateVersion(
      currentBuild['versionName']!,
      newBuildNumber.toString(),
    );
    print(
      'Successfully generated files and updated build number to $newBuildNumber.',
    );
  }
}
