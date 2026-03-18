import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/music_library_viewmodel.dart';
import 'artist_page.dart';
import 'home_page.dart';
import 'player_page.dart';
import 'search_page.dart';
import 'widgets/bottom_nav.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicLibraryViewModel>().loadLocalLibrary();
    });
  }

  void _openArtist() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArtistPage(
          onBack: () => Navigator.of(context).pop(),
          onOpenPlayer: _openPlayer,
        ),
      ),
    );
  }

  void _openPlayer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerPage(onBack: () => Navigator.of(context).pop()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onOpenArtist: _openArtist, onOpenPlayer: _openPlayer),
      const SearchPage(),
      HomePage(onOpenArtist: _openArtist, onOpenPlayer: _openPlayer),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNav(
        currentIndex: _index,
        onTap: (v) => setState(() => _index = v),
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: _openPlayer,
              backgroundColor: const Color(0xFF1C7DFF),
              child: const Icon(Icons.play_arrow_rounded),
            )
          : null,
    );
  }
}
