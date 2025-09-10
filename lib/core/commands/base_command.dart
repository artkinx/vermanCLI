import 'package:verman/core/services/file_service.dart';
import 'package:verman/models/pubspec_content_model.dart';

abstract class BaseCommand {
  final List<String> args;
  BaseCommand(this.args);
  Future<void> run();
  static Future<PubspecContentModel?> get getPubspecContent async =>
      await FileService.getPubspecContentAsync();
}
