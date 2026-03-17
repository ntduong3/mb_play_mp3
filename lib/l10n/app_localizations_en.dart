// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MB Play MP3';

  @override
  String helloUser(Object name) {
    return 'Hello, $name';
  }

  @override
  String get helloSubtitle => 'Ready to dive into the world of music?';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get recentListenings => 'Your Recent Listenings';

  @override
  String get topAlbums => 'Top Albums';

  @override
  String get searchPlaceholder => 'Search song, artist, album or playlist';

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
  String get playingNow => 'PLAYING NOW';

  @override
  String get nowPlayingSong => 'Baby Boy';

  @override
  String get nowPlayingArtist => 'Childish Gambino';

  @override
  String get artistName => 'Childish Gambino';

  @override
  String get artistBio =>
      'Donald McKinley Glover Jr. (born September 25, 1983), also known by the stage name Childish Gambino, is an American artist...';

  @override
  String get albums => 'Albums';

  @override
  String get popularTracks => 'Popular Tracks';

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
