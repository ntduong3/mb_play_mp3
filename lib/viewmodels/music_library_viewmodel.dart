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
  static const String allTracksQueueLabel = 'All MP3 Songs';
  static const String recentQueueLabel = 'Recently Played';
  static const String favoriteQueueLabel = 'Favorites';

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
  List<MusicTrack> _favoriteTracks = [];
  MusicTrack? _currentTrack;
  int _currentIndex = -1;
  Duration _currentDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  bool _isPlaying = false;
  bool _isShuffle = false;
  bool _isRepeat = false;
  String _activeQueueLabel = allTracksQueueLabel;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<MusicTrack> get tracks => List.unmodifiable(_tracks);
  List<MusicTrack> get queue => List.unmodifiable(_queue);
  List<MusicTrack> get recentTracks => List.unmodifiable(_recentTracks);
  List<MusicTrack> get favoriteTracks => List.unmodifiable(_favoriteTracks);
  MusicTrack? get currentTrack => _currentTrack;
  int get currentIndex => _currentIndex;
  Duration get currentDuration => _currentDuration;
  Duration get currentPosition => _currentPosition;
  bool get isPlaying => _isPlaying;
  bool get isShuffle => _isShuffle;
  bool get isRepeat => _isRepeat;
  String get activeQueueLabel => _activeQueueLabel;

  double get progress {
    if (_currentDuration.inMilliseconds <= 0) {
      return 0;
    }
    return (_currentPosition.inMilliseconds / _currentDuration.inMilliseconds)
        .clamp(0, 1)
        .toDouble();
  }

  bool isFavoriteTrack(MusicTrack? track) {
    if (track == null) {
      return false;
    }
    return _favoriteTracks.any((item) => item.id == track.id);
  }

  Future<void> loadLocalLibrary() async {
    _setLoading(true);
    try {
      _tracks = localService.getAllTracks();
      _recentTracks =
          _hydrateWithTracks(localService.getRecentTracks(), limit: 5);
      _favoriteTracks = _hydrateWithTracks(localService.getFavoriteTracks());
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
      _recentTracks =
          _hydrateWithTracks(localService.getRecentTracks(), limit: 5);
      _favoriteTracks = _hydrateWithTracks(localService.getFavoriteTracks());
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
      _recentTracks =
          _hydrateWithTracks(localService.getRecentTracks(), limit: 5);
      _favoriteTracks = _hydrateWithTracks(localService.getFavoriteTracks());
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
    String? queueLabel,
  }) async {
    if (fromQueue != null && fromQueue.isNotEmpty) {
      _queue = List<MusicTrack>.from(fromQueue);
      _activeQueueLabel = queueLabel ?? _activeQueueLabel;
    } else if (_queue.isEmpty) {
      _queue = List<MusicTrack>.from(_tracks);
      _activeQueueLabel = allTracksQueueLabel;
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
    await playTrack(
      _queue[index],
      fromQueue: _queue,
      queueLabel: _activeQueueLabel,
    );
  }

  Future<void> playRecentAt(int index) async {
    if (index < 0 || index >= _recentTracks.length) return;
    await playTrack(
      _recentTracks[index],
      fromQueue: _recentTracks,
      queueLabel: recentQueueLabel,
    );
  }

  Future<void> playFavoriteAt(int index) async {
    if (index < 0 || index >= _favoriteTracks.length) return;
    await playTrack(
      _favoriteTracks[index],
      fromQueue: _favoriteTracks,
      queueLabel: favoriteQueueLabel,
    );
  }

  Future<void> playFavorites({int startIndex = 0}) async {
    if (_favoriteTracks.isEmpty) return;
    final safeIndex = startIndex.clamp(0, _favoriteTracks.length - 1) as int;
    await playTrack(
      _favoriteTracks[safeIndex],
      fromQueue: _favoriteTracks,
      queueLabel: favoriteQueueLabel,
    );
  }

  Future<void> playAllTrackAt(int index) async {
    if (index < 0 || index >= _tracks.length) return;
    await playTrack(
      _tracks[index],
      fromQueue: _tracks,
      queueLabel: allTracksQueueLabel,
    );
  }

  Future<void> playAllTracks({int startIndex = 0}) async {
    if (_tracks.isEmpty) return;
    final safeIndex = startIndex.clamp(0, _tracks.length - 1) as int;
    await playTrack(
      _tracks[safeIndex],
      fromQueue: _tracks,
      queueLabel: allTracksQueueLabel,
    );
  }

  Future<void> playOrResume() async {
    if (_currentTrack == null) {
      if (_queue.isNotEmpty) {
        await playAtIndex(_currentIndex >= 0 ? _currentIndex : 0);
      } else if (_tracks.isNotEmpty) {
        _queue = List<MusicTrack>.from(_tracks);
        _activeQueueLabel = allTracksQueueLabel;
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

  Future<bool> toggleFavorite([MusicTrack? track]) async {
    final target = track ?? _currentTrack;
    if (target == null) {
      return false;
    }

    final existingIndex =
        _favoriteTracks.indexWhere((item) => item.id == target.id);
    if (existingIndex >= 0) {
      _favoriteTracks.removeAt(existingIndex);
      final removedCurrentWhileFavoriteQueue =
          _activeQueueLabel == favoriteQueueLabel &&
              _currentTrack?.id == target.id;
      if (removedCurrentWhileFavoriteQueue) {
        _useAllTracksQueuePreservingCurrent();
      } else {
        _queue = _refreshQueueForFavoritesRemoval(_queue, target.id);
      }
      await localService.saveFavoriteTracks(_favoriteTracks);
      _recalculateCurrentIndex();
      notifyListeners();
      return false;
    }

    final hydratedTrack = _resolveTrack(target);
    _favoriteTracks = [hydratedTrack, ..._favoriteTracks]
        .fold<List<MusicTrack>>(<MusicTrack>[], (items, item) {
      if (items.any((existing) => existing.id == item.id)) {
        return items;
      }
      items.add(item);
      return items;
    });
    await localService.saveFavoriteTracks(_favoriteTracks);
    notifyListeners();
    return true;
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
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

    final favoriteIndex =
        _favoriteTracks.indexWhere((track) => track.id == updatedTrack.id);
    if (favoriteIndex >= 0) {
      _favoriteTracks[favoriteIndex] = updatedTrack;
      unawaited(localService.saveFavoriteTracks(_favoriteTracks));
    }
  }

  void _syncQueueWithTracks({bool forceReset = false}) {
    if (_tracks.isEmpty) {
      _queue = [];
      _currentIndex = -1;
      _currentTrack = null;
      _currentDuration = Duration.zero;
      _currentPosition = Duration.zero;
      _activeQueueLabel = allTracksQueueLabel;
      notifyListeners();
      return;
    }

    if (forceReset || _queue.isEmpty) {
      _queue = List<MusicTrack>.from(_tracks);
      _currentIndex = 0;
      _currentTrack = _queue.first;
      _currentDuration = Duration(milliseconds: _currentTrack?.durationMs ?? 0);
      _currentPosition = Duration.zero;
      _activeQueueLabel = allTracksQueueLabel;
      notifyListeners();
      return;
    }

    _recentTracks = _hydrateWithTracks(_recentTracks, limit: 5);
    _favoriteTracks = _hydrateWithTracks(_favoriteTracks);
    _queue = _hydrateQueue(_queue, fallbackToAllTracks: true);
    _recalculateCurrentIndex();
    notifyListeners();
  }

  List<MusicTrack> _hydrateWithTracks(List<MusicTrack> source, {int? limit}) {
    if (source.isEmpty) {
      return const [];
    }

    final byId = {
      for (final track in _tracks) track.id: track,
    };

    var hydrated =
        source.map((track) => byId[track.id] ?? track).toList(growable: false);
    if (limit != null && hydrated.length > limit) {
      hydrated = hydrated.take(limit).toList(growable: false);
    }
    return hydrated;
  }

  List<MusicTrack> _hydrateQueue(
    List<MusicTrack> source, {
    required bool fallbackToAllTracks,
  }) {
    final byId = {
      for (final track in _tracks) track.id: track,
    };
    final hydrated =
        source.map((track) => byId[track.id] ?? track).toList(growable: false);
    if (hydrated.isNotEmpty) {
      return hydrated;
    }
    if (fallbackToAllTracks) {
      _activeQueueLabel = allTracksQueueLabel;
      return List<MusicTrack>.from(_tracks);
    }
    return const [];
  }

  MusicTrack _resolveTrack(MusicTrack track) {
    final match = _tracks.cast<MusicTrack?>().firstWhere(
          (item) => item?.id == track.id,
          orElse: () => null,
        );
    return match ?? track;
  }

  void _rememberRecent(MusicTrack track) {
    final updated = _hydrateWithTracks([
      _resolveTrack(track),
      ..._recentTracks.where((item) => item.id != track.id),
    ], limit: 5);
    _recentTracks = updated;
    unawaited(localService.saveRecentTracks(updated));
  }

  List<MusicTrack> _refreshQueueForFavoritesRemoval(
    List<MusicTrack> source,
    String removedId,
  ) {
    if (_activeQueueLabel != favoriteQueueLabel) {
      return source;
    }
    return source
        .where((track) => track.id != removedId)
        .toList(growable: false);
  }

  void _useAllTracksQueuePreservingCurrent() {
    _queue = List<MusicTrack>.from(_tracks);
    _activeQueueLabel = allTracksQueueLabel;
  }

  void _recalculateCurrentIndex() {
    if (_queue.isEmpty) {
      _currentIndex = -1;
      if (_activeQueueLabel == favoriteQueueLabel) {
        _activeQueueLabel = allTracksQueueLabel;
      }
      return;
    }

    if (_currentTrack == null) {
      _currentIndex = 0;
      _currentTrack = _queue.first;
      return;
    }

    final queueIndex =
        _queue.indexWhere((track) => track.id == _currentTrack!.id);
    if (queueIndex >= 0) {
      _currentIndex = queueIndex;
      _currentTrack = _queue[queueIndex];
      return;
    }

    _currentIndex = 0;
    _currentTrack = _queue.first;
    _currentDuration = Duration(milliseconds: _currentTrack?.durationMs ?? 0);
    _currentPosition = Duration.zero;
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
