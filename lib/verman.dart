import 'dart:io';
// ignore: unused_import
import 'package:path/path.dart' as p;
import 'package:verman/core/commands/build_command.dart';
import 'package:verman/core/commands/changelog_command.dart';
import 'package:verman/core/commands/check_platform_command.dart';
import 'package:verman/core/commands/current_command.dart';
import 'package:verman/core/commands/increment_command.dart';
import 'package:verman/core/commands/init_command.dart';
import 'package:verman/core/commands/package_version_command.dart';
import 'package:verman/core/commands/sync_command.dart';

import 'core/services/command_service.dart';

// Regular expression to find and capture the version string (e.g., 1.0.0+1)
final RegExp versionPattern = RegExp(r'version:\s*(\d+\.\d+\.\d+)(?:\+(\d+))?');

// /// Gets the version name and build number from the pubspec content.
// /// @param {String} content The pubspec file content.
// /// @returns {{versionName: String, buildNumber: String?}} The version data, or null if not found.
// Map<String, String?>? getVersion(String content) {
//   final match = versionPattern.firstMatch(content);
//   if (match != null) {
//     return {'versionName': match.group(1), 'buildNumber': match.group(2)};
//   }
//   return null;
// }

// /// Updates the version in the pubspec.yaml file.
// /// @param {String} newVersionName The new version name (e.g., "1.0.1").
// /// @param {String?} newBuildNumber The new build number, or null to keep existing.
// void updateVersion(String newVersionName, String? newBuildNumber) {
//   var pubspecContent = FileService.getPubspecContent();
//   if (pubspecContent == null) return;

//   final newVersionString =
//       'version: $newVersionName${newBuildNumber != null ? '+$newBuildNumber' : ''}';
//   final updatedContent = pubspecContent.content.replaceFirst(
//     versionPattern,
//     newVersionString,
//   );

//   FileService.writePubspecContent(
//     updatedContent,
//     newVersionName,
//     newBuildNumber,
//   );
// }

/// The main entry point for the CLI tool.
/// @param {List&lt;String&gt;} arguments The command line arguments.
void main(List<String> arguments) {
  if (arguments.isEmpty || arguments.first == 'help') {
    print(CommandService.helpHelp);
    return;
  }

  if (arguments.contains('help') || arguments.contains('-h')) {
    if (arguments.first == 'current') {
      print(CommandService.currentHelp);
    }

    if (arguments.first == 'increment') {
      print(CommandService.incrementHelp);
    }

    if (arguments.first == 'build') {
      print(CommandService.buildHelp);
    }

    if (arguments.first == 'check') {
      print(CommandService.platformCheckHelp);
    }

    if (arguments.first == 'sync') {
      print(CommandService.syncHelp);
    }

    if (arguments.first == 'log') {
      print(CommandService.logHelp);
    }

    return;
  }

  final command = arguments.first;
  final args = arguments.skip(1).toList();

  switch (command) {
    case 'current':
      CurrentCommand(args).run();
      break;
    case 'increment':
      IncrementCommand(args).run();
      break;
    case 'init':
      InitCommand(args).run();
      break;
    case 'check':
      CheckPlatformCommand(args).run();
      break;
    case 'sync':
      SyncCommand(args).run();
      break;
    case 'version':
      PackageVersionCommand(args).run();
      break;
    case 'build':
      BuildCommand(args).run();
      break;
    case 'log':
      ChangelogCommand(args).run();
      break;
    default:
      stderr.writeln(
        '\'$command\' is not a recognized command. Type "verman help" for a list of commands.',
      );
      exit(1);
  }
}
