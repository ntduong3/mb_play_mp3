import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

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

  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  MusicLibraryViewModel({
    required this.apiClient,
    required this.localService,
    required this.audioService,
  }) {
    _remoteService = RemoteMusicService(apiClient: apiClient);
    _bindPlayerStreams();
  }

  bool _isLoading = false;
  String? _error;
  List<MusicTrack> _tracks = [];
  List<MusicTrack> _queue = [];
  List<MusicTrack> _recentTracks = [];
  MusicTrack? _currentTrack;
  int _currentIndex = -1;
  Duration _currentDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  bool _isPlaying = false;
  bool _isShuffle = false;
  bool _isRepeat = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<MusicTrack> get tracks => List.unmodifiable(_tracks);
  List<MusicTrack> get queue => List.unmodifiable(_queue);
  List<MusicTrack> get recentTracks => List.unmodifiable(_recentTracks);
  MusicTrack? get currentTrack => _currentTrack;
  int get currentIndex => _currentIndex;
  Duration get currentDuration => _currentDuration;
  Duration get currentPosition => _currentPosition;
  bool get isPlaying => _isPlaying;
  bool get isShuffle => _isShuffle;
  bool get isRepeat => _isRepeat;

  double get progress {
    if (_currentDuration.inMilliseconds <= 0) {
      return 0;
    }
    return (_currentPosition.inMilliseconds / _currentDuration.inMilliseconds)
        .clamp(0, 1)
        .toDouble();
  }

  Future<void> loadLocalLibrary() async {
    _setLoading(true);
    try {
      _tracks = localService.getAllTracks();
      _recentTracks = _hydrateRecentTracks(localService.getRecentTracks());
      _error = null;
      _syncQueueWithTracks();
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
      final scanned = <MusicTrack>[];
      for (final file in files.whereType<File>()) {
        scanned.add(await _buildTrack(file));
      }

      await localService.clearAll();
      await localService.saveTracks(scanned);
      _tracks = localService.getAllTracks();
      _recentTracks = _hydrateRecentTracks(localService.getRecentTracks());
      _error = null;
      _syncQueueWithTracks(forceReset: true);
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
      _recentTracks = _hydrateRecentTracks(localService.getRecentTracks());
      _error = null;
      _syncQueueWithTracks();
    } catch (e) {
      _error = 'Sync failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> playTrack(
    MusicTrack track, {
    List<MusicTrack>? fromQueue,
  }) async {
    if (fromQueue != null && fromQueue.isNotEmpty) {
      _queue = List<MusicTrack>.from(fromQueue);
    } else if (_queue.isEmpty) {
      _queue = List<MusicTrack>.from(_tracks);
    }

    final index = _queue.indexWhere((item) => item.id == track.id);
    if (index >= 0) {
      _currentIndex = index;
    }

    _currentTrack = track;
    _currentPosition = Duration.zero;
    _isPlaying = true;
    _rememberRecent(track);
    notifyListeners();

    final duration = await audioService.playFile(track.filePath);
    _updateCurrentDuration(duration, fallbackTrack: track);
  }

  Future<void> playAtIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    await playTrack(_queue[index], fromQueue: _queue);
  }

  Future<void> playRecentAt(int index) async {
    if (index < 0 || index >= _recentTracks.length) return;
    await playTrack(_recentTracks[index], fromQueue: _recentTracks);
  }

  Future<void> playOrResume() async {
    if (_currentTrack == null) {
      if (_queue.isNotEmpty) {
        await playAtIndex(_currentIndex >= 0 ? _currentIndex : 0);
      } else if (_tracks.isNotEmpty) {
        _queue = List<MusicTrack>.from(_tracks);
        await playAtIndex(0);
      }
      return;
    }

    await audioService.resume();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> pause() async {
    await audioService.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> seekToFraction(double value) async {
    if (_currentDuration.inMilliseconds <= 0) return;
    final milliseconds = (_currentDuration.inMilliseconds * value).round();
    final target = Duration(milliseconds: milliseconds);
    _currentPosition = target;
    notifyListeners();
    await audioService.seek(target);
  }

  Future<void> playNext() async {
    if (_queue.isEmpty) return;

    final nextIndex = _isShuffle
        ? _randomIndexExcluding(_currentIndex, _queue.length)
        : (_currentIndex + 1) % _queue.length;
    await playAtIndex(nextIndex);
  }

  Future<void> playPrevious() async {
    if (_queue.isEmpty) return;

    final previousIndex = _isShuffle
        ? _randomIndexExcluding(_currentIndex, _queue.length)
        : (_currentIndex - 1 + _queue.length) % _queue.length;
    await playAtIndex(previousIndex);
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    notifyListeners();
  }

  void setQueue(List<MusicTrack> tracks, {int startIndex = 0}) {
    _queue = List<MusicTrack>.from(tracks);
    if (_queue.isEmpty) {
      _currentIndex = -1;
      _currentTrack = null;
    } else {
      final boundedIndex = startIndex < 0
          ? 0
          : startIndex >= _queue.length
              ? _queue.length - 1
              : startIndex;
      _currentIndex = boundedIndex;
      _currentTrack = _queue[_currentIndex];
    }
    notifyListeners();
  }

  Future<MusicTrack> _buildTrack(File file) async {
    final duration = await audioService.probeDuration(file.path);
    return MusicTrack(
      id: file.path,
      title: _fileNameOnly(file.path),
      artist: 'Unknown',
      filePath: file.path,
      durationMs: duration?.inMilliseconds ?? 0,
      lastModifiedMs: file.lastModifiedSync().millisecondsSinceEpoch,
    );
  }

  void _bindPlayerStreams() {
    _durationSub = audioService.durationStream.listen((duration) {
      _updateCurrentDuration(duration);
    });

    _positionSub = audioService.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _playerStateSub = audioService.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _handleTrackCompleted();
        return;
      }
      notifyListeners();
    });
  }

  void _updateCurrentDuration(Duration? duration, {MusicTrack? fallbackTrack}) {
    final track = fallbackTrack ?? _currentTrack;
    _currentDuration =
        duration ?? Duration(milliseconds: track?.durationMs ?? 0);

    if (track != null && _currentDuration.inMilliseconds > 0) {
      final updatedTrack = track.copyWith(
        durationMs: _currentDuration.inMilliseconds,
      );
      _replaceTrack(updatedTrack);
    }

    notifyListeners();
  }

  void _replaceTrack(MusicTrack updatedTrack) {
    _currentTrack = updatedTrack;

    final tracksIndex =
        _tracks.indexWhere((track) => track.id == updatedTrack.id);
    if (tracksIndex >= 0) {
      _tracks[tracksIndex] = updatedTrack;
    }

    final queueIndex =
        _queue.indexWhere((track) => track.id == updatedTrack.id);
    if (queueIndex >= 0) {
      _queue[queueIndex] = updatedTrack;
      _currentIndex = queueIndex;
    }

    final recentIndex =
        _recentTracks.indexWhere((track) => track.id == updatedTrack.id);
    if (recentIndex >= 0) {
      _recentTracks[recentIndex] = updatedTrack;
      unawaited(localService.saveRecentTracks(_recentTracks));
    }
  }

  void _syncQueueWithTracks({bool forceReset = false}) {
    if (_tracks.isEmpty) {
      _queue = [];
      _currentIndex = -1;
      _currentTrack = null;
      _currentDuration = Duration.zero;
      _currentPosition = Duration.zero;
      notifyListeners();
      return;
    }

    if (forceReset || _queue.isEmpty) {
      _queue = List<MusicTrack>.from(_tracks);
      _currentIndex = 0;
      _currentTrack = _queue.first;
      _currentDuration = Duration(milliseconds: _currentTrack?.durationMs ?? 0);
      _currentPosition = Duration.zero;
      notifyListeners();
      return;
    }

    if (_currentTrack != null) {
      final queueIndex =
          _queue.indexWhere((track) => track.id == _currentTrack!.id);
      final source = queueIndex >= 0 ? _queue : _tracks;
      final replacementIndex =
          source.indexWhere((track) => track.id == _currentTrack!.id);
      if (replacementIndex >= 0) {
        _currentTrack = source[replacementIndex];
        _currentDuration =
            Duration(milliseconds: _currentTrack?.durationMs ?? 0);
      }
    }

    notifyListeners();
  }

  List<MusicTrack> _hydrateRecentTracks(List<MusicTrack> source) {
    if (source.isEmpty) {
      return const [];
    }

    final byId = {
      for (final track in _tracks) track.id: track,
    };

    return source
        .map((track) => byId[track.id] ?? track)
        .take(5)
        .toList(growable: false);
  }

  void _rememberRecent(MusicTrack track) {
    final updated = _hydrateRecentTracks([
      track,
      ..._recentTracks.where((item) => item.id != track.id),
    ]);
    _recentTracks = updated;
    unawaited(localService.saveRecentTracks(updated));
  }

  Future<void> _handleTrackCompleted() async {
    if (_queue.isEmpty) return;

    if (_isRepeat && _currentIndex >= 0) {
      await playAtIndex(_currentIndex);
      return;
    }

    await playNext();
  }

  int _randomIndexExcluding(int current, int length) {
    if (length <= 1) return 0;
    final random = Random();
    int next = current;
    while (next == current) {
      next = random.nextInt(length);
    }
    return next;
  }

  String _fileNameOnly(String path) {
    final parts = path.split(Platform.pathSeparator);
    return parts.isEmpty ? path : parts.last;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    audioService.dispose();
    super.dispose();
  }
}
