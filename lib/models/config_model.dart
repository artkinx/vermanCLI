import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:verman/core/services/file_service.dart';
import 'package:yaml/yaml.dart' as yaml;

class ConfigModel {
  /// Tells verman where to look for your ios info.plist
  /// if left undefined then value will be defaulted to '~/ios/runner/info.plist'
  final String iosInfoPlistPath;

  /// Tells verman where to look for your ios android gradle file
  /// if left undefined then value will be defaulted to '~/android/app/build.gradle'
  final String androidGradlePath;

  /// Allows you define a custom path to your verman config
  /// If this is provided, then [ios] and [android] parameters will be overriden
  /// even if they are provided in pubspec.yaml
  final String configFilePath;

  const ConfigModel({
    required this.iosInfoPlistPath,
    required this.androidGradlePath,
    required this.configFilePath,
  });

  /// Initializes the model for use within the tool
  static ConfigModel init() {
    // Fetch the pubspec.yaml content
    var configContent = FileService.getPubspecContent();

    // convert it to a yaml document
    var pubspecYaml = yaml.loadYamlDocument(configContent!.content);

    // retrieve the config portion
    var vermanConfig = Map<String, dynamic>.from(
      pubspecYaml.contents.value['verman_config'],
    );

    // extract the path forf the custom from the config
    var path = vermanConfig['path'] == null
        ? ''
        : p.join(Directory.current.path, vermanConfig['path']);

    // if the path is not empty, then load the custom config file
    if (path.isNotEmpty) {
      var content = FileService.getFileContent(path);
      var contentYaml = yaml.loadYamlDocument(content!.content);
      vermanConfig.addAll(
        Map<String, dynamic>.from(contentYaml.contents.value),
      );
    }

    // if the config is not empty, then return the model
    if (vermanConfig.isNotEmpty) {
      return ConfigModel.fromJson(vermanConfig);
    }

    // if the config is empty, then return the default model
    return ConfigModel(
      androidGradlePath: p.join(
        Directory.current.path,
        'android',
        'app',
        'build.gradle',
      ),
      iosInfoPlistPath: p.join(
        Directory.current.path,
        'ios',
        'Runner',
        'Info.plist',
      ),
      configFilePath: '',
    );
  }

  ConfigModel copyWith({String? iosInfoPlistPath, String? androidGradlePath}) {
    return ConfigModel(
      iosInfoPlistPath: iosInfoPlistPath ?? this.iosInfoPlistPath,
      androidGradlePath: androidGradlePath ?? this.androidGradlePath,
      configFilePath: configFilePath,
    );
  }

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      iosInfoPlistPath: json["ios"] as String? ?? '',
      androidGradlePath: json["android"] as String? ?? '',
      configFilePath: json["path"] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "path": configFilePath,
      "ios": iosInfoPlistPath,
      "android": androidGradlePath,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
