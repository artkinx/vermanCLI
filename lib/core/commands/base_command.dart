import 'package:verman/core/services/file_service.dart';
import 'package:verman/models/config_model.dart';
import 'package:verman/models/pubspec_content_model.dart';

abstract class BaseCommand {
  final List<String> args;
  BaseCommand(this.args);
  Future<void> run();
  ConfigModel get config => ConfigModel.init();
  static Future<PubspecContentModel?> get getPubspecContent async =>
      await FileService.getPubspecContentAsync();
}
