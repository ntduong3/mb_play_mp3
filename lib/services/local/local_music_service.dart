import 'package:hive/hive.dart';

import '../../models/music_track.dart';
import 'hive_service.dart';

class LocalMusicService {
  Box<Map> get _tracksBox => Hive.box<Map>(HiveService.tracksBox);
  Box<List> get _recentBox => Hive.box<List>(HiveService.recentTracksBox);

  List<MusicTrack> getAllTracks() {
    return _tracksBox.values
        .map((e) => MusicTrack.fromMap(e))
        .toList(growable: false);
  }

  List<MusicTrack> getRecentTracks() {
    final items = _recentBox
            .get(HiveService.recentTracksKey, defaultValue: <dynamic>[]) ??
        <dynamic>[];
    return items
        .whereType<Map>()
        .map(MusicTrack.fromMap)
        .toList(growable: false);
  }

  Future<void> saveTracks(List<MusicTrack> tracks) async {
    for (final track in tracks) {
      await _tracksBox.put(track.id, track.toMap());
    }
  }

  Future<void> saveRecentTracks(List<MusicTrack> tracks) async {
    await _recentBox.put(
      HiveService.recentTracksKey,
      tracks.map((track) => track.toMap()).toList(growable: false),
    );
  }

  Future<void> clearAll() async {
    await _tracksBox.clear();
  }
}
