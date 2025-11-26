import 'dart:io';
import 'package:verman/core/services/command_service.dart';

import '../base_command.dart';

class ChangelogCommand extends BaseCommand {
  ChangelogCommand(super.args);

  @override
  Future<void> run() async {
    // Checks for the existence of the changelog file only in the default location for now
    final changelogFile = File('CHANGELOG.md');
    if (!changelogFile.existsSync()) {
      stderr.writeln('Error: CHANGELOG.md not found.');
      print('Should I create a new CHANGELOG.md file? (y/n)');
      final response = stdin.readLineSync();
      if (response != 'y') {
        print('Aborting...Goodbye!😒');
        return;
      }
      changelogFile.createSync(recursive: true);
    }

    print('Reading file contents');
    var lines = await changelogFile.readAsLines();

    var id = '';

    try {
      // Checks for the id in the most recent entry in file
      // and extracts the id if it exists
      for (var line in lines) {
        if (line.trim().startsWith('##')) {
          id = line.trim().split(' ').last;
          break;
        }
      }
    } catch (e) {
      stderr.writeln('An error occurred whilst parsing the changelog.');
      return;
    }

    // Get commit history
    final result = await Process.run('git', [
      'log',
      '--pretty=format:%s;%h',
      // checks if there is a recent entry
      // then adds the parameter to restrict the command to only return newer commits by the commitId
      if (id.isNotEmpty) '$id..HEAD',
    ], runInShell: true);

    // checks if git return an error
    if (result.exitCode != 0) {
      stderr.writeln('Error: Unable to read git commit history.');
      return;
    }

    // retrieve the git output
    final commits = (result.stdout as String).split('\n');
    if (commits.isEmpty) {
      stderr.writeln('No commits found.');
      return;
    }

    // double checks if the git output is empty
    if (commits.length == 1 && commits.first.isEmpty && id.isNotEmpty) {
      stderr.writeln('No new commits found.');
      return;
    }

    // Format changelog entry
    final buffer = StringBuffer();

    var data = await BaseCommand.getPubspecContent;

    final version = CommandService.getVersion(data?.content ?? '') ?? {};

    // This should be the new coupled with the id of the first commit
    var commitId = commits.first.split(';').last;
    if (version.isEmpty) {
      buffer.writeln('## Ureleased');
    } else {
      buffer.writeln(
        '## ${version['versionName'] ?? ''}+${version['buildNumber'] ?? ''}  $commitId',
      );
    }

    var groupedCommits = commits.groupBy((s) {
      var key = s.split(':').first;
      return key;
    });

    for (var element in groupedCommits.entries) {
      if (element.key.trim().isEmpty) {
        continue;
      }
      buffer.writeln('  ### ${element.key}');
      for (final commit in element.value) {
        if (commit.trim().isEmpty) {
          continue;
        }
        var splitted = commit.split(';');
        splitted.removeLast();
        buffer.writeln('    - ${splitted.join()}');
      }
    }

    // Append to CHANGELOG.md

    final content = changelogFile.readAsStringSync();
    final updatedContent = '$buffer\n$content';
    changelogFile.writeAsStringSync(updatedContent);
    print('✅ Changelog updated with latest commits.');
  }
}

extension GroupByExtension<T> on Iterable<T> {
  /// Groups the elements of the iterable by the value returned by [keyOf].
  Map<K, List<T>> groupBy<K>(K Function(T element) keyOf) {
    var result = <K, List<T>>{};
    for (var element in this) {
      final key = keyOf(element);
      (result[key] ??= []).add(element);
    }
    return result;
  }
}
