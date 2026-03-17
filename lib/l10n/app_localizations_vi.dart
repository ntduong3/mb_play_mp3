// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'MB Play MP3';

  @override
  String helloUser(Object name) {
    return 'Xin chào, $name';
  }

  @override
  String get helloSubtitle => 'Sẵn sàng đắm chìm trong thế giới âm nhạc?';

  @override
  String get recommendations => 'Gợi ý';

  @override
  String get recentListenings => 'Nghe gần đây';

  @override
  String get topAlbums => 'Album nổi bật';

  @override
  String get searchPlaceholder => 'Tìm bài hát, nghệ sĩ, album hoặc playlist';

  @override
  String get genreRap => 'Rap';

  @override
  String get genreRock => 'Rock';

  @override
  String get genreElectronic => 'Electronic';

  @override
  String get genreBlues => 'Blues';

  @override
  String get genreJazz => 'Jazz';

  @override
  String get playingNow => 'ĐANG PHÁT';

  @override
  String get nowPlayingSong => 'Baby Boy';

  @override
  String get nowPlayingArtist => 'Childish Gambino';

  @override
  String get artistName => 'Childish Gambino';

  @override
  String get artistBio =>
      'Donald McKinley Glover Jr. (sinh 25 tháng 9, 1983), còn được biết đến với nghệ danh Childish Gambino, là một nghệ sĩ người Mỹ...';

  @override
  String get albums => 'Album';

  @override
  String get popularTracks => 'Bài hát nổi bật';

  @override
  String get albumAwaken => 'Awaken, My Love';

  @override
  String get albumBecause => 'Because of The ...';

  @override
  String get albumMeta => 'Album • 2016';

  @override
  String get trackRedbone => 'Redbone';

  @override
  String get track3005 => '3005';

  @override
  String get splashTitle => 'MUSING';
}
