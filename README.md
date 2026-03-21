# Local Mp3

`Local Mp3` is a Flutter offline music player focused on playing MP3 files directly from the device. The app uses an MVVM structure, Hive for local persistence, and `just_audio` for playback.

## Main Features
- Scan local storage for MP3 files on the device.
- Play music from a full `All Playlist` queue.
- Save and manage favorite songs.
- Track recently played songs.
- Use a dedicated player screen with queue, shuffle, repeat, seek, and favorite actions.
- Store local library state with Hive for faster reloads.

## Tech Stack
- Flutter
- Provider
- Hive
- just_audio
- permission_handler
- google_fonts

## Project Structure
- `lib/models`: song data models.
- `lib/viewmodels`: playback and library state management.
- `lib/views`: app pages and UI flows.
- `lib/views/widgets`: reusable UI widgets.
- `lib/services/local`: Hive, permission, and local file scanning.
- `lib/services/audio`: audio playback integration.
- `lib/l10n`: app localization files.

## Current App Flow
- `Home`: recommendations, recently played, and favorites preview.
- `Search`: visual genre/search landing page.
- `All Playlist`: shows the full MP3 library and plays items in the all-tracks queue.
- `Liked`: dedicated favorite playlist page.
- `Player`: full playback controls and active queue details.

## Getting Started
1. Install Flutter SDK.
2. Run `flutter pub get`.
3. Connect a device or start an emulator.
4. Run `flutter run`.

## Android Permissions
The app reads local audio files and requests runtime permission through `permission_handler`.

Required permissions in `android/app/src/main/AndroidManifest.xml`:
- `android.permission.READ_MEDIA_AUDIO` for Android 13+.
- `android.permission.READ_EXTERNAL_STORAGE` for Android 12 and below.

## Build Release APK
From the project root:

```powershell
cd android
.\gradlew.bat assembleRelease
```

Generated APK:
- `build/app/outputs/apk/release/app-release.apk`

If Gradle cache permission is limited in your environment, using a local `GRADLE_USER_HOME` inside the workspace is also supported.

## Assets
Important assets currently used by the app:
- `assets/images/icon.png`: source icon for app branding.
- `assets/images/cover_awaken.gif`: animated cover art used in the player and playlists.
- `assets/images/artist_header.png`, `reco_*.png`, `genre_*.png`, `album_*.png`: UI artwork.

## Notes
- This repository is an app project, so `pubspec.lock` should be committed.
- Local music metadata is hydrated back from Hive after scans and app restarts.
- The all-tracks queue and favorite queue are handled separately for cleaner playback behavior.
