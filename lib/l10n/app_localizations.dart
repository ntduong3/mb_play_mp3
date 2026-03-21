import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('vi'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'Local Mp3'**
  String get appTitle;

  /// No description provided for @helloUser.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào, {name}'**
  String helloUser(Object name);

  /// No description provided for @helloSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'S?n sàng d?m chìm trong th? gi?i âm nh?c?'**
  String get helloSubtitle;

  /// No description provided for @recommendations.
  ///
  /// In vi, this message translates to:
  /// **'G?i ý'**
  String get recommendations;

  /// No description provided for @recentListenings.
  ///
  /// In vi, this message translates to:
  /// **'Nghe g?n dây'**
  String get recentListenings;

  /// No description provided for @topAlbums.
  ///
  /// In vi, this message translates to:
  /// **'Album n?i b?t'**
  String get topAlbums;

  /// No description provided for @searchPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tìm bài hát, ngh? si, album ho?c playlist'**
  String get searchPlaceholder;

  /// No description provided for @genreRap.
  ///
  /// In vi, this message translates to:
  /// **'Rap'**
  String get genreRap;

  /// No description provided for @genreRock.
  ///
  /// In vi, this message translates to:
  /// **'Rock'**
  String get genreRock;

  /// No description provided for @genreElectronic.
  ///
  /// In vi, this message translates to:
  /// **'Electronic'**
  String get genreElectronic;

  /// No description provided for @genreBlues.
  ///
  /// In vi, this message translates to:
  /// **'Blues'**
  String get genreBlues;

  /// No description provided for @genreJazz.
  ///
  /// In vi, this message translates to:
  /// **'Jazz'**
  String get genreJazz;

  /// No description provided for @playingNow.
  ///
  /// In vi, this message translates to:
  /// **'ÐANG PHÁT'**
  String get playingNow;

  /// No description provided for @nowPlayingSong.
  ///
  /// In vi, this message translates to:
  /// **'Baby Boy'**
  String get nowPlayingSong;

  /// No description provided for @nowPlayingArtist.
  ///
  /// In vi, this message translates to:
  /// **'Childish Gambino'**
  String get nowPlayingArtist;

  /// No description provided for @artistName.
  ///
  /// In vi, this message translates to:
  /// **'Childish Gambino'**
  String get artistName;

  /// No description provided for @artistBio.
  ///
  /// In vi, this message translates to:
  /// **'Donald McKinley Glover Jr. (sinh 25 tháng 9, 1983), còn du?c bi?t d?n v?i ngh? danh Childish Gambino, là m?t ngh? si ngu?i M?...'**
  String get artistBio;

  /// No description provided for @albums.
  ///
  /// In vi, this message translates to:
  /// **'Album'**
  String get albums;

  /// No description provided for @popularTracks.
  ///
  /// In vi, this message translates to:
  /// **'Bài hát n?i b?t'**
  String get popularTracks;

  /// No description provided for @albumAwaken.
  ///
  /// In vi, this message translates to:
  /// **'Awaken, My Love'**
  String get albumAwaken;

  /// No description provided for @albumBecause.
  ///
  /// In vi, this message translates to:
  /// **'Because of The ...'**
  String get albumBecause;

  /// No description provided for @albumMeta.
  ///
  /// In vi, this message translates to:
  /// **'Album • 2016'**
  String get albumMeta;

  /// No description provided for @trackRedbone.
  ///
  /// In vi, this message translates to:
  /// **'Redbone'**
  String get trackRedbone;

  /// No description provided for @track3005.
  ///
  /// In vi, this message translates to:
  /// **'3005'**
  String get track3005;

  /// No description provided for @splashTitle.
  ///
  /// In vi, this message translates to:
  /// **'MUSING'**
  String get splashTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
