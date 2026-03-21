// ignore_for_file: lines_longer_than_80_chars

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'viewmodels/music_library_viewmodel.dart';
import 'views/app_shell.dart';
import 'services/api/api_client.dart';
import 'services/api/api_config.dart';
import 'services/local/local_music_service.dart';
import 'services/audio/audio_player_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient(
      config: const ApiConfig(baseUrl: 'https://example.com'),
    );
    final localService = LocalMusicService();
    final audioService = AudioPlayerService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MusicLibraryViewModel(
            apiClient: apiClient,
            localService: localService,
            audioService: audioService,
          ),
        ),
      ],
      child: MaterialApp(
        useInheritedMediaQuery: true,
        locale: const Locale('vi'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) return const Locale('vi');
          for (final supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
          return const Locale('vi');
        },
        builder: DevicePreview.appBuilder,
        title: 'Local Mp3',
        theme: AppTheme.light(),
        home: const AppShell(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
