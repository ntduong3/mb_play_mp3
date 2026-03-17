import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> ensureAudioReadPermission() async {
    if (!Platform.isAndroid) return true;

    final audioStatus = await Permission.audio.status;
    if (audioStatus.isGranted) return true;

    final audioRequest = await Permission.audio.request();
    if (audioRequest.isGranted) return true;

    // Fallback for Android < 13
    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) return true;

    final storageRequest = await Permission.storage.request();
    return storageRequest.isGranted;
  }
}