import 'package:flutter/material.dart';

import 'widgets/app_background.dart';
import 'widgets/genre_card.dart';
import '../l10n/app_localizations.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3442),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white70),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.searchPlaceholder,
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  GenreCard(
                    title: l10n.genreRap,
                    colors: const [Color(0xFFF4A400), Color(0xFFB37400)],
                    imagePath: 'assets/images/genre_1.png',
                  ),
                  GenreCard(
                    title: l10n.genreRock,
                    colors: const [Color(0xFFE81E25), Color(0xFFB3161B)],
                    imagePath: 'assets/images/genre_2.png',
                  ),
                  GenreCard(
                    title: l10n.genreElectronic,
                    colors: const [Color(0xFF6C1DFF), Color(0xFF4313A6)],
                    imagePath: 'assets/images/genre_3.png',
                  ),
                  GenreCard(
                    title: l10n.genreBlues,
                    colors: const [Color(0xFF1E6DFF), Color(0xFF1541A8)],
                    imagePath: 'assets/images/genre_4.png',
                  ),
                  GenreCard(
                    title: l10n.genreJazz,
                    colors: const [Color(0xFF15C7E2), Color(0xFF0D7E93)],
                    imagePath: 'assets/images/genre_5.png',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
