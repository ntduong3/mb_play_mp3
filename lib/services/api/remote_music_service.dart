import '../../models/music_track.dart';
import '../api/api_client.dart';

class RemoteMusicService {
  final ApiClient apiClient;

  RemoteMusicService({required this.apiClient});

  Future<List<MusicTrack>> fetchTracks() async {
    // TODO: replace with real endpoint
    final res = await apiClient.get<List<dynamic>>('/tracks');
    final data = res.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(MusicTrack.fromMap)
        .toList(growable: false);
  }
}