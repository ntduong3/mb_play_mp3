import 'package:flutter/material.dart';

import 'widgets/app_background.dart';
import 'widgets/cover_art.dart';
import 'widgets/mini_player.dart';
import 'widgets/section_title.dart';
import '../l10n/app_localizations.dart';

class ArtistPage extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onOpenPlayer;

  const ArtistPage({
    super.key,
    required this.onBack,
    required this.onOpenPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 140),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: onBack,
                          icon: const Icon(Icons.chevron_left_rounded, size: 34),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 280,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/artist_header.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      l10n.artistBio,
                      style: const TextStyle(color: Color(0xFF97A5BE)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SectionTitle(title: l10n.albums),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CoverArt(
                              size: 120,
                              radius: 24,
                              imagePath: index == 0
                                  ? 'assets/images/cover_awaken.png'
                                  : 'assets/images/album_2.png',
                            ),
                            const SizedBox(height: 8),
                            Text(index == 0 ? l10n.albumAwaken : l10n.albumBecause),
                            const SizedBox(height: 4),
                            Text(
                              l10n.albumMeta,
                              style: const TextStyle(color: Color(0xFF97A5BE)),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemCount: 2,
                    ),
                  ),
                  SectionTitle(title: l10n.popularTracks),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: const Text('1', style: TextStyle(fontWeight: FontWeight.w700)),
                    title: Text(
                      l10n.trackRedbone,
                      style: const TextStyle(color: Color(0xFF37C8FF)),
                    ),
                    trailing: const Text('6:19'),
                    onTap: onOpenPlayer,
                  ),
                  const Divider(indent: 24, endIndent: 24, height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: const Text('2', style: TextStyle(fontWeight: FontWeight.w700)),
                    title: Text(l10n.track3005),
                    trailing: const Text('3:54'),
                    onTap: onOpenPlayer,
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MiniPlayer(
                      title: l10n.trackRedbone,
                      artist: l10n.artistName,
                      coverPath: 'assets/images/cover_awaken.png',
                    ),
                    Container(
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Color(0xFF232C3B),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.home_rounded),
                          Icon(Icons.search_rounded),
                          Icon(Icons.widgets_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
