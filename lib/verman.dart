import 'dart:io';


import 'package:verman/core/commands/build_command.dart';
import 'package:verman/core/commands/check_platform_command.dart';
import 'package:verman/core/commands/current_command.dart';

import 'core/commands/init_command.dart';
import 'core/commands/increment_command.dart';
import 'core/commands/package_version_command.dart';
import 'core/commands/sync_command.dart';
import 'core/services/command_service.dart';

/// The main entry point for the CLI tool.
/// @param {List&lt;String&gt;} arguments The command line arguments.
Future<void> main(List<String> arguments) async {
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

    if (arguments.first == 'check-platforms') {
      print(CommandService.platformCheckHelp);
    }

    if (arguments.first == 'sync') {
      print(CommandService.syncHelp);
    }

    if (arguments.first == 'init') {
      print(CommandService.initHelp);
    }

    return;
  }

  final command = arguments.first;
  final args = arguments.skip(1).toList();

  switch (command) {
    case 'current':
      await CurrentCommand(args).run();
      break;

    case 'increment':
      await IncrementCommand(args).run();
      break;

    case 'init':
      await InitCommand(args).run();
      break;

    case 'build':
      await BuildCommand(args).run();
      break;
    
    case 'check-platforms':
      await CheckPlatformCommand(args).run();
      break;

    case 'version':
      PackageVersionCommand(args).run();
      break;
      
    case 'sync':
      await SyncCommand(args).run();
      break;

    default:
      stderr.writeln(
        '\'$command\' is not a recognized command. Try running "verman help or verman" for a list of commands.',
      );
      exit(1);
  }
}
