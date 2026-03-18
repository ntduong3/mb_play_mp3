import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  Future<Duration?> playFile(String filePath) async {
    final duration = await _player.setFilePath(filePath);
    await _player.play();
    return duration;
  }

  Future<Duration?> probeDuration(String filePath) async {
    final probe = AudioPlayer();
    try {
      return await probe.setFilePath(filePath);
    } finally {
      await probe.dispose();
    }
  }

  Future<void> resume() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> stop() => _player.stop();

  Future<void> seek(Duration position) => _player.seek(position);

  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Duration? get duration => _player.duration;
  Duration get position => _player.position;

  Future<void> dispose() async {
    await _player.dispose();
  }
}
