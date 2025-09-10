import '../services/file_service.dart';
import 'base_command.dart';

/// Command to get the version of the package.
class PackageVersionCommand extends BaseCommand {
  PackageVersionCommand(super.args);

  @override
  Future<void> run() async {
    final versionInfo = await FileService.getSelfVersion();
    if (versionInfo != null) {
      final version = versionInfo['versionName'];
      final build = versionInfo['buildNumber'];
      print('verman version $version${build != null ? '+$build' : ''}');
    } else {
      print('Could not determine verman version.');
    }
  }
}
