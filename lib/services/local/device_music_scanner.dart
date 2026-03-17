import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DeviceMusicScanner {
  Future<List<FileSystemEntity>> scanMp3Files() async {
    final candidates = <Directory>[];

    final appDir = await getApplicationDocumentsDirectory();
    candidates.add(appDir);

    if (Platform.isAndroid) {
      final musicDirs = await getExternalStorageDirectories(
        type: StorageDirectory.music,
      );
      if (musicDirs != null) {
        candidates.addAll(musicDirs);
      }

      final downloadsDirs = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      if (downloadsDirs != null) {
        candidates.addAll(downloadsDirs);
      }

      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        candidates.add(externalDir);
      }

      // Common shared folders
      candidates.add(Directory('/storage/emulated/0/Music'));
      candidates.add(Directory('/storage/emulated/0/Download'));
      candidates.add(Directory('/sdcard/Music'));
      candidates.add(Directory('/sdcard/Download'));
    }

    final results = <FileSystemEntity>[];
    final visited = <String>{};

    for (final dir in candidates) {
      final path = dir.path;
      if (visited.contains(path)) continue;
      visited.add(path);

      if (!await dir.exists()) continue;

      try {
        await for (final f in dir.list(recursive: true, followLinks: false)) {
          if (f is File && f.path.toLowerCase().endsWith('.mp3')) {
            results.add(f);
          }
        }
      } catch (_) {
        // Ignore folders without access
      }
    }

    return results;
  }
}