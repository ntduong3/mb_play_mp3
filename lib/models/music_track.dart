class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final String filePath;
  final int durationMs;
  final int lastModifiedMs;

  const MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.filePath,
    required this.durationMs,
    required this.lastModifiedMs,
  });

  MusicTrack copyWith({
    String? id,
    String? title,
    String? artist,
    String? filePath,
    int? durationMs,
    int? lastModifiedMs,
  }) {
    return MusicTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      filePath: filePath ?? this.filePath,
      durationMs: durationMs ?? this.durationMs,
      lastModifiedMs: lastModifiedMs ?? this.lastModifiedMs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'filePath': filePath,
      'durationMs': durationMs,
      'lastModifiedMs': lastModifiedMs,
    };
  }

  factory MusicTrack.fromMap(Map<dynamic, dynamic> map) {
    return MusicTrack(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      filePath: map['filePath'] as String,
      durationMs: map['durationMs'] as int,
      lastModifiedMs: map['lastModifiedMs'] as int,
    );
  }
}