import 'dart:io' show stderr;

import '../base_command.dart';
import 'changelog_command.dart' show ChangelogCommand;

class GenerateCommand extends BaseCommand {
  GenerateCommand(super.args);

  @override
  Future<void> run() async {
    if (args.isEmpty) {
      stderr.writeln('Error: No type specified.');
      return;
    }

    if (args.first == 'log') {
      ChangelogCommand(args).run();
    }
  }
}
