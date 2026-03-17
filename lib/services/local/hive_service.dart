import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String tracksBox = 'tracks_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(tracksBox);
  }
}