import '../services/file_service.dart';
import 'base_command.dart';

/// Command to get the version of the package.
class PackageVersionCommand extends BaseCommand {
  PackageVersionCommand(super.args);

  @override
  Future<void> run() async {
    final packageInfo = await FileService.getPackageInfo();
    print('Verman: ${packageInfo.version}+${packageInfo.buildNumber}');
  }
}
