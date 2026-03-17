import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/music_track.dart';
import '../services/api/api_client.dart';
import '../services/api/remote_music_service.dart';
import '../services/audio/audio_player_service.dart';
import '../services/local/device_music_scanner.dart';
import '../services/local/local_music_service.dart';
import '../services/local/permission_service.dart';

class MusicLibraryViewModel extends ChangeNotifier {
  final ApiClient apiClient;
  final LocalMusicService localService;
  final AudioPlayerService audioService;

  late final RemoteMusicService _remoteService;
  final DeviceMusicScanner _scanner = DeviceMusicScanner();
  final PermissionService _permissionService = PermissionService();

  MusicLibraryViewModel({
    required this.apiClient,
    required this.localService,
    required this.audioService,
  }) {
    _remoteService = RemoteMusicService(apiClient: apiClient);
  }

  bool _isLoading = false;
  String? _error;
  List<MusicTrack> _tracks = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<MusicTrack> get tracks => _tracks;

  Future<void> loadLocalLibrary() async {
    _setLoading(true);
    try {
      _tracks = localService.getAllTracks();
      _error = null;
    } catch (e) {
      _error = 'Load local failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> scanDeviceAndSave() async {
    _setLoading(true);
    try {
      final granted = await _permissionService.ensureAudioReadPermission();
      if (!granted) {
        _error = 'Permission denied: cannot read audio files.';
        return;
      }

      final files = await _scanner.scanMp3Files();
      final scanned = files
          .whereType<File>()
          .map((f) => MusicTrack(
                id: f.path,
                title: _fileNameOnly(f.path),
                artist: 'Unknown',
                filePath: f.path,
                durationMs: 0,
                lastModifiedMs: f.lastModifiedSync().millisecondsSinceEpoch,
              ))
          .toList(growable: false);
      await localService.saveTracks(scanned);
      _tracks = localService.getAllTracks();
      _error = null;
    } catch (e) {
      _error = 'Scan failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> syncFromApi() async {
    _setLoading(true);
    try {
      final remoteTracks = await _remoteService.fetchTracks();
      await localService.saveTracks(remoteTracks);
      _tracks = localService.getAllTracks();
      _error = null;
    } catch (e) {
      _error = 'Sync failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> play(MusicTrack track) async {
    await audioService.playFile(track.filePath);
  }

  Future<void> pause() async {
    await audioService.pause();
  }

  String _fileNameOnly(String path) {
    final parts = path.split(Platform.pathSeparator);
    return parts.isEmpty ? path : parts.last;
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
