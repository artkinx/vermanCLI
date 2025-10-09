import 'package:verman/core/commands/base_command.dart';

import '../services/command_service.dart';

class CurrentCommand extends BaseCommand {
  CurrentCommand(super.args);

  /// Gets the current build version values
  @override
  Future<void> run() async {
    final content = await BaseCommand.getPubspecContent;
    if (content == null) return;
    final version = CommandService.getVersion(content.content);
    if (version == null) return;
    print(
      'Current version: ${version['versionName']}${version['buildNumber'] != null ? '+${version['buildNumber']}' : ''}',
    );
  }
}
