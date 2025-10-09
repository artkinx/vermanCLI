import 'dart:io';

import 'package:verman/core/services/command_service.dart';

import 'base_command.dart';

class IncrementCommand extends BaseCommand {
  IncrementCommand(super.args);

  /// Increases the build version values
  /// [major] or [minor] or [patch] are the accepted options
  @override
  Future<void> run() async {
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

    final content = await BaseCommand.getPubspecContent;
    if (content == null) {
      exit(1);
    }

    final currentVersion = CommandService.getVersion(content.content);
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

    CommandService.updateVersion(newVersionName, newBuildNumber.toString());
  }
}
