import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/music_track.dart';
import '../viewmodels/music_library_viewmodel.dart';
import 'widgets/app_background.dart';
import 'widgets/cover_art.dart';

class FavoritePlaylistPage extends StatelessWidget {
  final VoidCallback onOpenPlayer;

  const FavoritePlaylistPage({
    super.key,
    required this.onOpenPlayer,
  });

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatStatDuration(List<MusicTrack> tracks) {
    final totalMinutes = tracks.fold<int>(
      0,
      (sum, track) => sum + Duration(milliseconds: track.durationMs).inMinutes,
    );

    if (totalMinutes >= 60) {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
    }

    return '${totalMinutes}m';
  }

  Future<void> _playAll(BuildContext context, MusicLibraryViewModel vm) async {
    await vm.playFavorites();
    if (!context.mounted) return;
    onOpenPlayer();
  }

  Future<void> _playTrack(
    BuildContext context,
    MusicLibraryViewModel vm,
    int index,
  ) async {
    await vm.playFavoriteAt(index);
    if (!context.mounted) return;
    onOpenPlayer();
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    MusicLibraryViewModel vm,
    MusicTrack track,
  ) async {
    final added = await vm.toggleFavorite(track);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added ? 'Added to favorites' : 'Removed from favorites',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 900),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MusicLibraryViewModel>();
    final favoriteTracks = vm.favoriteTracks;
    final currentTrack = vm.currentTrack;
    final totalDuration = favoriteTracks.fold<Duration>(
      Duration.zero,
      (sum, track) => sum + Duration(milliseconds: track.durationMs),
    );

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Favorite Playlist',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Your heart-picked songs in one place.',
                              style: TextStyle(color: AppTheme.textSoft),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFFF6B7A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF8576B),
                          Color(0xFFFA8F70),
                          Color(0xFF1C7DFF)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33F8576B),
                          blurRadius: 24,
                          offset: Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              favoriteTracks.isEmpty
                                  ? 'Empty now'
                                  : '${favoriteTracks.length} saved',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Made for your replay mood',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          favoriteTracks.isEmpty
                              ? 'Tap the heart on the player page and your playlist will appear here instantly.'
                              : 'Jump back into the songs you loved most without searching again.',
                          style: const TextStyle(
                            height: 1.45,
                            color: Color(0xFFF8F5F6),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _StatChip(
                              icon: Icons.music_note_rounded,
                              label: '${favoriteTracks.length} tracks',
                            ),
                            _StatChip(
                              icon: Icons.schedule_rounded,
                              label: _formatStatDuration(favoriteTracks),
                            ),
                            _StatChip(
                              icon: Icons.graphic_eq_rounded,
                              label: totalDuration == Duration.zero
                                  ? 'Ready to fill'
                                  : 'Now vibing',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: favoriteTracks.isEmpty
                                ? null
                                : () => _playAll(context, vm),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF101C32),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text(
                              'Play favorite playlist',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (favoriteTracks.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyFavoritesState(),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 14),
                    child: Row(
                      children: [
                        const Text(
                          'Saved tracks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDuration(totalDuration),
                          style: const TextStyle(color: AppTheme.textSoft),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                  sliver: SliverList.builder(
                    itemCount: favoriteTracks.length,
                    itemBuilder: (context, index) {
                      final track = favoriteTracks[index];
                      final isCurrent = currentTrack?.id == track.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(26),
                            onTap: () => _playTrack(context, vm, index),
                            child: Ink(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? const Color(0xFF1A2D49)
                                    : const Color(0xFF121B27),
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(
                                  color: isCurrent
                                      ? const Color(0xFF37C8FF)
                                      : Colors.white10,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      const CoverArt(
                                        size: 62,
                                        radius: 20,
                                        imagePath:
                                            'assets/images/cover_awaken.gif',
                                      ),
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isCurrent
                                              ? const Color(0xFF37C8FF)
                                              : const Color(0xFFFF6B7A),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Icon(
                                          isCurrent && vm.isPlaying
                                              ? Icons.graphic_eq_rounded
                                              : Icons.favorite_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                track.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            if (isCurrent)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 8),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF223653),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          999),
                                                ),
                                                child: Text(
                                                  vm.isPlaying
                                                      ? 'Playing'
                                                      : 'Paused',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF8EDEFF),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          track.artist,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppTheme.textSoft,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Text(
                                              _formatDuration(
                                                Duration(
                                                    milliseconds:
                                                        track.durationMs),
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              '|',
                                              style: TextStyle(
                                                  color: AppTheme.textSoft),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Liked #${index + 1}',
                                              style: const TextStyle(
                                                color: AppTheme.textSoft,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () =>
                                        _toggleFavorite(context, vm, track),
                                    icon: const Icon(
                                      Icons.favorite_rounded,
                                      color: Color(0xFFFF6B7A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  const _EmptyFavoritesState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF121B27),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF8576B), Color(0xFFFA8F70)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'No favorite songs yet',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const Text(
                'Open any song in the player and tap the heart icon. Your personal playlist will build itself here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSoft,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
