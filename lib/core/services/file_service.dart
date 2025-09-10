import 'dart:io';

import 'package:path/path.dart' as p;

import '../../models/pubspec_content_model.dart';

class FileService {
  /// Reads and returns the content of the pubspec.yaml file.
  /// @returns {PubspecContentModel?} The file content, or null if not found.
  static PubspecContentModel? getPubspecContent() {
    final pubspecFilePath = p.join(Directory.current.path, 'pubspec.yaml');
    final pubspecFile = File(pubspecFilePath);

    if (!pubspecFile.existsSync()) {
      stderr.writeln('Error: pubspec.yaml not found in the current directory.');
      return null;
    }

    try {
      return PubspecContentModel(
        path: pubspecFilePath,
        content: pubspecFile.readAsStringSync(),
      );
    } on FileSystemException catch (e) {
      stderr.writeln('Error reading pubspec.yaml: ${e.message}');
      return null;
    }
  }

  /// Reads and returns the content of the pubspec.yaml file.
  /// @returns {PubspecContentModel?} The file content, or null if not found.
  static Future<PubspecContentModel?> getPubspecContentAsync() async {
    final pubspecFilePath = p.join(Directory.current.path, 'pubspec.yaml');
    final pubspecFile = File(pubspecFilePath);

    if (!pubspecFile.existsSync()) {
      stderr.writeln('Error: pubspec.yaml not found in the current directory.');
      return null;
    }

    try {
      var fileContent = await pubspecFile.readAsString();
      return PubspecContentModel(path: pubspecFilePath, content: fileContent);
    } on FileSystemException catch (e) {
      stderr.writeln('Error reading pubspec.yaml: ${e.message}');
      return null;
    }
  }

  ///Write a new content to the pubspec.yaml file
  ///
  static void writePubspecContent(
    String newContent,
    dynamic newVersionName,
    dynamic newBuildNumber,
  ) {
    final pubspecFilePath = p.join(Directory.current.path, 'pubspec.yaml');
    final pubspecFile = File(pubspecFilePath);

    try {
      pubspecFile.writeAsStringSync(newContent);
      print(
        'Success: Updated version to $newVersionName${newBuildNumber != null ? '+$newBuildNumber' : ''}',
      );
    } on FileSystemException catch (e) {
      stderr.writeln('Error writing to pubspec.yaml: ${e.message}');
    }
  }

  /// Reads and returns the version from the Android build.gradle file.
  /// @returns {Map&lt;String, String?&gt;?} A map with 'versionName' and 'buildNumber',
  /// or null if the file is not found/readable, or an empty map if parsing fails.
  static Map<String, String?>? getAndroidVersion() {
    var gradleFilePath = p.join(
      Directory.current.path,
      'android',
      'app',
      'build.gradle',
    );
    var gradleFile = File(gradleFilePath);

    if (!gradleFile.existsSync()) {
      gradleFilePath = p.join(
        Directory.current.path,
        'android',
        'app',
        'build.gradle.kts',
      );
      gradleFile = File(gradleFilePath);

      if (!gradleFile.existsSync()) {
        return null; // File not found
      }
    }

    try {
      final content = gradleFile.readAsStringSync();

      // First, check for Flutter's variable-based versions
      final variableNameMatch = RegExp(
        r'versionName\s+=\s+flutter\.versionName',
      ).hasMatch(content);
      final variableCodeMatch = RegExp(
        r'versionCode\s+=\s+flutter\.versionCode',
      ).hasMatch(content);

      if (variableNameMatch && variableCodeMatch) {
        return {
          'versionName': 'flutter.versionName',
          'buildNumber': 'flutter.versionCode',
        };
      }

      // If not found, check for hardcoded versions
      final versionNameMatch = RegExp(
        r'versionName\s+"([^"]+)"',
      ).firstMatch(content);
      final versionCodeMatch = RegExp(
        r'versionCode\s+(\d+)',
      ).firstMatch(content);
      if (versionNameMatch != null && versionCodeMatch != null) {
        return {
          'versionName': versionNameMatch.group(1),
          'buildNumber': versionCodeMatch.group(1),
        };
      }
      return {}; // File found but version not parsed
    } on FileSystemException {
      return null; // Error reading file
    }
  }

  /// Reads and returns the version from the iOS Info.plist file.
  /// @returns {Map&lt;String, String?&gt;?} A map with 'versionName' and 'buildNumber',
  /// or null if the file is not found/readable, or an empty map if parsing fails.
  static Map<String, String?>? getIosVersion() {
    final plistFilePath = p.join(
      Directory.current.path,
      'ios',
      'Runner',
      'Info.plist',
    );
    final plistFile = File(plistFilePath);

    if (!plistFile.existsSync()) {
      return null; // File not found
    }

    try {
      final content = plistFile.readAsStringSync();
      final versionNameMatch = RegExp(
        r'<key>CFBundleShortVersionString</key>\s*<string>([^<]+)</string>',
      ).firstMatch(content);
      final buildNumberMatch = RegExp(
        r'<key>CFBundleVersion</key>\s*<string>([^<]+)</string>',
      ).firstMatch(content);

      if (versionNameMatch != null && buildNumberMatch != null) {
        return {
          'versionName': versionNameMatch.group(1),
          'buildNumber': buildNumberMatch.group(1),
        };
      }
      return {}; // File found but version not parsed
    } on FileSystemException {
      return null; // Error reading file
    }
  }

  /// Updates the version in the Android build.gradle file.
  /// @returns {bool} True if the file was updated, false otherwise.
  static bool updateAndroidVersion(String versionName, String buildNumber) {
    var gradleFilePath = p.join(
      Directory.current.path,
      'android',
      'app',
      'build.gradle',
    );
    var gradleFile = File(gradleFilePath);

    if (!gradleFile.existsSync()) {
      gradleFilePath = p.join(
        Directory.current.path,
        'android',
        'app',
        'build.gradle.kts',
      );
      gradleFile = File(gradleFilePath);
      if (!gradleFile.existsSync()) {
        return false; // File not found
      }
    }

    try {
      var content = gradleFile.readAsStringSync();
      var originalContent = content;

      // Replace versionName
      final nameRegex = RegExp(r'versionName\s+"[^"]+"');
      if (nameRegex.hasMatch(content)) {
        content = content.replaceFirst(nameRegex, 'versionName "$versionName"');
      }

      // Replace versionCode
      final codeRegex = RegExp(r'versionCode\s+\d+');
      if (codeRegex.hasMatch(content)) {
        content = content.replaceFirst(codeRegex, 'versionCode $buildNumber');
      }

      if (content != originalContent) {
        gradleFile.writeAsStringSync(content);
        return true;
      }
      return false; // No changes made
    } on FileSystemException {
      return false; // Error reading/writing file
    }
  }

  /// Initializes the info.plist file.
  /// with the necessary key and value for versionName and buildNumber.
  /// @returns {bool} True is the file was initialized, false otherwise.
  static bool initializeIosVersion() {
    final plistFilePath = p.join(
      Directory.current.path,
      'ios',
      'Runner',
      'Info.plist',
    );

    final plistFile = File(plistFilePath);

    if (!plistFile.existsSync()) {
      return false; // File not found
    }

    try {
      var content = plistFile.readAsStringSync();
      var originalContent = content;

      // Add CFBundleShortVersionString
      if (!content.contains('<key>CFBundleShortVersionString</key>')) {
        content = content.replaceFirst(
          '<dict>',
          '<dict>\n     <key>CFBundleShortVersionString</key>\n<string>\$(FLUTTER_BUILD_NAME)</string>',
        );
      }

      // Add CFBundleVersion
      if (!content.contains('<key>CFBundleVersion</key>')) {
        content = content.replaceFirst(
          '<dict>',
          '<dict>\n     <key>CFBundleVersion</key>\n<string>\$(FLUTTER_BUILD_NUMBER)</string>',
        );
      }

      if (content != originalContent) {
        plistFile.writeAsStringSync(content);
        return true;
      }
    } catch (e) {
      return false; // Error reading/writing file
    }
    return false; // No changes made
  }

  /// Updates the version in the iOS Info.plist file.
  /// @returns {bool} True if the file was updated, false otherwise.
  static bool updateIosVersion(String versionName, String buildNumber) {
    final plistFilePath = p.join(
      Directory.current.path,
      'ios',
      'Runner',
      'Info.plist',
    );
    final plistFile = File(plistFilePath);

    if (!plistFile.existsSync()) {
      return false; // File not found
    }

    try {
      var content = plistFile.readAsStringSync();
      var originalContent = content;

      // Replace CFBundleShortVersionString
      final nameRegex = RegExp(
        r'(<key>CFBundleShortVersionString</key>\s*<string>)[^<]+(</string>)',
      );
      if (nameRegex.hasMatch(content)) {
        content = content.replaceFirst(nameRegex, '\$1$versionName\$2');
      }

      // Replace CFBundleVersion
      final codeRegex = RegExp(
        r'(<key>CFBundleVersion</key>\s*<string>)[^<]+(</string>)',
      );
      if (codeRegex.hasMatch(content)) {
        content = content.replaceFirst(codeRegex, '\$1$buildNumber\$2');
      }

      if (content != originalContent) {
        plistFile.writeAsStringSync(content);
        return true;
      }
      return false; // No changes made
    } on FileSystemException {
      return false; // Error reading/writing file
    }
  }
}
