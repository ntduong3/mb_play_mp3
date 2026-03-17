# MB Play MP3

Base Flutter music player using MVVM and Hive (offline-first).

## Structure
- lib/models
- lib/views
- lib/viewmodels
- lib/services

## Quick start
1. Create a Flutter project (if not already) then copy `lib/` and `pubspec.yaml` into it.
2. Run `flutter pub get`.
3. Start the app.

## Android permissions
Add these to `android/app/src/main/AndroidManifest.xml`:
- `android.permission.READ_MEDIA_AUDIO` (Android 13+)
- `android.permission.READ_EXTERNAL_STORAGE` (Android 12 and below)

Runtime permission is requested via `permission_handler`.

Notes:
- `DeviceMusicScanner` scans Music/Download plus app directories.
- `ApiClient` includes auth header injection, retry, and error mapping.