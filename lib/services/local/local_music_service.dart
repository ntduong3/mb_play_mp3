import 'package:hive/hive.dart';

import '../../models/music_track.dart';
import 'hive_service.dart';

class LocalMusicService {
  Box<Map> get _box => Hive.box<Map>(HiveService.tracksBox);

  List<MusicTrack> getAllTracks() {
    return _box.values
        .map((e) => MusicTrack.fromMap(e))
        .toList(growable: false);
  }

  Future<void> saveTracks(List<MusicTrack> tracks) async {
    for (final track in tracks) {
      await _box.put(track.id, track.toMap());
    }
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}