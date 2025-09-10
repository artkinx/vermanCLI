
# Changelog

## 🛠️ Upcoming - v1.2.0
- 🪄 Changelog automation feature (auto-generates release from commit history)
- 🔧 Configuration file for customizing automation behavior
_____

## 1.1.3+5

- **fix**: Fixed bug that caused increment to behave wrongly

## 1.1.2+4

- **fix**: General bug fixes

## 1.1.1+3

- **docs**: Updates `Changelog.md` with upcoming changes
- **propose**: Introduce `init` command to create default verman.yaml configuration file
- **fix**: Update platform version checking and syncing to respect custom paths
- **fix**: Streamlined Commands Service for better performance and maintainability

## 1.1.0+2

- **fix**: `platform support` now correctly shows support for only Android and iOS with more platforms to come.

## 1.1.0+1

- **fix**: `check-platforms` now correctly handles projects using Flutter variables for versioning.

## 1.1.0

- **feat**: Add `sync` command to update platform files from `pubspec.yaml`.
- **feat**: Add `check-platforms` command to verify version consistency.
- **feat**: `increment` command now also increments the build number.
- **fix**: Commands now correctly handle projects using Flutter variables for versioning.
- **docs**: Add comprehensive `README.md` and `LICENSE`.
- **ci**: Add automated tests for all CLI commands.

## 1.0.0

- Initial version.
