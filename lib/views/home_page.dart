import 'package:flutter/material.dart';

import '../views/widgets/app_background.dart';
import '../views/widgets/cover_art.dart';
import '../views/widgets/section_title.dart';
import '../l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onOpenArtist;

  const HomePage({super.key, required this.onOpenArtist});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBackground(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.helloUser('Omie'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.helloSubtitle,
                            style: const TextStyle(color: Color(0xFF97A5BE)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B7CFF), Color(0xFF6FE6FF)],
                        ),
                      ),
                      child: const Icon(Icons.face_rounded),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionTitle(title: l10n.recommendations),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 210,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) {
                    final title = index == 0 ? 'Night Vocals' : 'Dance All Night';
                    final img = index == 0
                        ? 'assets/images/reco_1.png'
                        : 'assets/images/reco_2.png';
                    return GestureDetector(
                      onTap: onOpenArtist,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              img,
                              width: 170,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '30 Songs • 1 hours 3 min',
                            style: TextStyle(color: Color(0xFF97A5BE)),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 18),
                  itemCount: 2,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionTitle(title: l10n.recentListenings),
            ),
            SliverList.builder(
              itemCount: 3,
              itemBuilder: (_, index) {
                final titles = ['Redbone', '3005', 'Les'];
                final durations = ['6:19', '3:54', '5:17'];
                final images = [
                  'assets/images/cover_awaken.png',
                  'assets/images/album_2.png',
                  'assets/images/album_2.png',
                ];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: CoverArt(
                    size: 42,
                    radius: 12,
                    imagePath: images[index],
                  ),
                  title: Text(titles[index]),
                  trailing: Text(durations[index]),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            SliverToBoxAdapter(
              child: SectionTitle(title: l10n.topAlbums),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) => CoverArt(
                    size: 150,
                    radius: 26,
                    imagePath: index == 0
                        ? 'assets/images/cover_awaken.png'
                        : 'assets/images/album_2.png',
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemCount: 3,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }
}
