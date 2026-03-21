import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/music_track.dart';
import '../viewmodels/music_library_viewmodel.dart';
import '../views/widgets/app_background.dart';
import '../views/widgets/cover_art.dart';
import '../views/widgets/section_title.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onOpenArtist;
  final VoidCallback onOpenPlayer;

  const HomePage({
    super.key,
    required this.onOpenArtist,
    required this.onOpenPlayer,
  });

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _playRecent(
      BuildContext context, MusicLibraryViewModel vm, int index) async {
    await vm.playRecentAt(index);
    if (!context.mounted) return;
    onOpenPlayer();
  }

  Future<void> _playFavorite(
      BuildContext context, MusicLibraryViewModel vm, int index) async {
    await vm.playFavoriteAt(index);
    if (!context.mounted) return;
    onOpenPlayer();
  }

  Widget _buildTrackTile({
    required BuildContext context,
    required MusicLibraryViewModel vm,
    required MusicTrack track,
    required int index,
    required String subtitle,
    required Future<void> Function() onTap,
  }) {
    final isActive = vm.currentTrack?.id == track.id;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:
                  isActive ? const Color(0xFF182B45) : const Color(0xFF121B27),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isActive ? const Color(0xFF37C8FF) : Colors.white10,
              ),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CoverArt(
                      size: 52,
                      radius: 16,
                      imagePath: 'assets/images/cover_awaken.gif',
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C7DFF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Icon(
                        isActive && vm.isPlaying
                            ? Icons.graphic_eq_rounded
                            : Icons.play_arrow_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF97A5BE),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDuration(Duration(milliseconds: track.durationMs)),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '#${index + 1}',
                      style: const TextStyle(
                          color: Color(0xFF97A5BE), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFF121B27),
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF97A5BE), height: 1.45),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<MusicLibraryViewModel>();
    final recentTracks = vm.recentTracks;
    final favoriteTracks = vm.favoriteTracks;

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) {
                    final title =
                        index == 0 ? 'Night Vocals' : 'Dance All Night';
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
                            '30 Songs • 1 hour 3 min',
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
            if (recentTracks.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmptyCard(
                  'No tracks in recently played yet. Start playing music to save the latest 5 songs.',
                ),
              )
            else
              SliverList.builder(
                itemCount: recentTracks.length,
                itemBuilder: (context, index) {
                  final track = recentTracks[index];
                  return _buildTrackTile(
                    context: context,
                    vm: vm,
                    track: track,
                    index: index,
                    subtitle: 'Recent 5 • ${track.artist}',
                    onTap: () => _playRecent(context, vm, index),
                  );
                },
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 10),
            ),
            SliverToBoxAdapter(
              child: SectionTitle(title: 'Favorites'),
            ),
            if (favoriteTracks.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmptyCard(
                  'Tap the heart while playing to add songs to your favorites list.',
                ),
              )
            else
              SliverList.builder(
                itemCount: favoriteTracks.length,
                itemBuilder: (context, index) {
                  final track = favoriteTracks[index];
                  return _buildTrackTile(
                    context: context,
                    vm: vm,
                    track: track,
                    index: index,
                    subtitle: 'Favorites • ${track.artist}',
                    onTap: () => _playFavorite(context, vm, index),
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
                        ? 'assets/images/cover_awaken.gif'
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
