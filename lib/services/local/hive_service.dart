import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String tracksBox = 'tracks_box';
  static const String recentTracksBox = 'recent_tracks_box';
  static const String favoriteTracksBox = 'favorite_tracks_box';
  static const String recentTracksKey = 'recent_tracks';
  static const String favoriteTracksKey = 'favorite_tracks';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(tracksBox);
    await Hive.openBox<List>(recentTracksBox);
    await Hive.openBox<List>(favoriteTracksBox);
  }
}
