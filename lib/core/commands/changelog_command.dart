import 'dart:io';
import 'base_command.dart';

class ChangelogCommand extends BaseCommand {
  ChangelogCommand(super.args);

  @override
  Future<void> run() async {
    // Get commit history
    final result = await Process.run('git', [
      'log',
      '--pretty=format:%s',
    ], runInShell: true);
    if (result.exitCode != 0) {
      stderr.writeln('Error: Unable to read git commit history.');
      return;
    }
    final commits = (result.stdout as String).split('\n');
    if (commits.isEmpty) {
      stderr.writeln('No commits found.');
      return;
    }

    // Format changelog entry
    final buffer = StringBuffer();
    buffer.writeln('## ${args.isNotEmpty ? args[0] : 'Unreleased'}');
    for (final commit in commits) {
      buffer.writeln('- $commit');
    }
    // Append to CHANGELOG.md
    final changelogFile = File('CHANGELOG.md');
    if (!changelogFile.existsSync()) {
      stderr.writeln('Error: CHANGELOG.md not found.');
      return;
    }
    final content = changelogFile.readAsStringSync();
    final updatedContent = '$buffer\n$content';
    changelogFile.writeAsStringSync(updatedContent);
    print('✅ Changelog updated with latest commits.');
  }
}
