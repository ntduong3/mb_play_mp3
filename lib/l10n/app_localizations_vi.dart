// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Local Mp3';

  @override
  String helloUser(Object name) {
    return 'Xin chào, $name';
  }

  @override
  String get helloSubtitle => 'S?n sàng d?m chìm trong th? gi?i âm nh?c?';

  @override
  String get recommendations => 'G?i ý';

  @override
  String get recentListenings => 'Nghe g?n dây';

  @override
  String get topAlbums => 'Album n?i b?t';

  @override
  String get searchPlaceholder => 'Tìm bài hát, ngh? si, album ho?c playlist';

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
  String get playingNow => 'ÐANG PHÁT';

  @override
  String get nowPlayingSong => 'Baby Boy';

  @override
  String get nowPlayingArtist => 'Childish Gambino';

  @override
  String get artistName => 'Childish Gambino';

  @override
  String get artistBio =>
      'Donald McKinley Glover Jr. (sinh 25 tháng 9, 1983), còn du?c bi?t d?n v?i ngh? danh Childish Gambino, là m?t ngh? si ngu?i M?...';

  @override
  String get albums => 'Album';

  @override
  String get popularTracks => 'Bài hát n?i b?t';

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
