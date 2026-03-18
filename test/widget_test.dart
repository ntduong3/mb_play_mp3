import 'package:flutter_test/flutter_test.dart';

import 'package:mb_play_mp3/models/music_track.dart';

void main() {
  test('MusicTrack map serialization round-trip', () {
    const track = MusicTrack(
      id: 'song-1',
      title: 'Song 1',
      artist: 'Artist 1',
      filePath: '/music/song-1.mp3',
      durationMs: 123000,
      lastModifiedMs: 456000,
    );

    final restored = MusicTrack.fromMap(track.toMap());

    expect(restored.id, track.id);
    expect(restored.title, track.title);
    expect(restored.artist, track.artist);
    expect(restored.filePath, track.filePath);
    expect(restored.durationMs, track.durationMs);
    expect(restored.lastModifiedMs, track.lastModifiedMs);
  });
}
