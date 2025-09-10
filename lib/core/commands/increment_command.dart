import 'dart:io';

import 'package:verman/core/services/command_service.dart';

import 'base_command.dart';

class IncrementCommand extends BaseCommand {
  IncrementCommand(super.args);

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
    if (content != null) {
      final versionData = CommandService.getVersion(content.content);
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
  }
}
