import 'file_service.dart';

class CommandService {
  // Regular expression to find and capture the version string (e.g., 1.0.0+1)
  static final RegExp _versionPattern = RegExp(
    r'version:\s*(\d+\.\d+\.\d+)(?:\+(\d+))?',
  );

  static const String initHelp = '''
  Initialize verman in the current project.
  Usage: dart run verman init
  Action: Creates a verman.yaml file in the base project directory
  ''';

  static const String syncHelp = '''
          Updates Android and iOS version files to match pubspec.yaml.
          Usage: dart run verman sync
          Note: This only works for hardcoded versions, not Flutter variables like `\$(FLUTTER_BUILD_NAME)`.
        ''';

  static const String logHelp = '''
          Updates your change log file based on your git commits.
          Usage: dart run verman log
        ''';

  static const String incrementHelp = '''
          Increments the version by major, minor, or patch.
          Usage: dart run verman increment [part]

          major: Increments the major version.
          minor: Increments the minor version.
          patch: Increments the patch version.

          Example: "dart run verman increment patch"
          ''';

  static const String currentHelp = '''
          Displays the current version from pubspec.yaml.
          Usage: dart run verman current
          Example: "Current version: 1.0.0+1"
        ''';

  static const String buildHelp = '''
          Simulates running 'flutter pub run build_runner build' and increments the build number.
          Usage: dart run verman build
          Example: "Running 'flutter pub run build_runner build'...
          Successfully generated files and updated build number to 2."
        ''';

  static const String platformCheckHelp = '''
          Compares the pubspec.yaml version against Android and iOS version files.
          Usage: dart run verman check-platforms
          Example output:
          Checking platform files against pubspec version: 1.0.0+1...
          Android (android/app/build.gradle) version: 1.0.0 (1) - ✅ In Sync
          iOS (ios/Runner/Info.plist) version: 1.0.0 (1) - ✅ In Sync
        ''';

  static const String helpHelp = '''
Available commands for Flutter projects:
  init                  - Initialize verman in the current project (optional).
  current               - Displays the current version from pubspec.yaml.
  increment [part]      - Increments the version by major, minor, or patch.
                          Example: increment patch
  build                 - Simulates running 'flutter pub run build_runner build' and increments the build number.
  sync                  - Syncs the pubspec.yaml version to platform-specific files.
  check                 - Verifies that platform-specific files reference the correct version.
  version               - Checks the currently installed version of the verman tool.
    ''';

  /// Updates the version in the pubspec.yaml file.
  /// @param {String} newVersionName The new version name (e.g., "1.0.1").
  /// @param {String?} newBuildNumber The new build number, or null to keep existing.
  static void updateVersion(String newVersionName, String? newBuildNumber) {
    var pubspecContent = FileService.getPubspecContent();
    if (pubspecContent == null) return;

    final newVersionString =
        'version: $newVersionName${newBuildNumber != null ? '+$newBuildNumber' : ''}';
    final updatedContent = pubspecContent.content.replaceFirst(
      _versionPattern,
      newVersionString,
    );

    FileService.writePubspecContent(
      updatedContent,
      newVersionName,
      newBuildNumber,
    );
  }

  /// Gets the version name and build number from the pubspec content.
  /// @param {String} content The pubspec file content.
  /// @returns {{versionName: String, buildNumber: String?}} The version data, or null if not found.
  static Map<String, String?>? getVersion(String content) {
    final match = _versionPattern.firstMatch(content);
    if (match != null) {
      return {'versionName': match.group(1), 'buildNumber': match.group(2)};
    }
    return null;
  }

  static Map<String, String?>? getAndroidVersion(String gradleFilePath) {
    return FileService.getAndroidVersion(gradleFilePath);
  }

  static Map<String, String?>? getIosVersion(String plistFilePath) {
    return FileService.getIosVersion(plistFilePath);
  }

  static bool updateAndroidVersion(String versionName, String buildNumber) {
    return FileService.updateAndroidVersion(versionName, buildNumber);
  }

  static bool updateIosVersion(String versionName, String buildNumber) {
    return FileService.updateIosVersion(versionName, buildNumber);
  }
}
