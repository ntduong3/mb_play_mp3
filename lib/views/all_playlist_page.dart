import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/music_track.dart';
import '../viewmodels/music_library_viewmodel.dart';
import 'widgets/app_background.dart';
import 'widgets/cover_art.dart';

class AllPlaylistPage extends StatelessWidget {
  final VoidCallback onOpenPlayer;

  const AllPlaylistPage({
    super.key,
    required this.onOpenPlayer,
  });

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatLargeDuration(List<MusicTrack> tracks) {
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
    await vm.playAllTracks();
    if (!context.mounted) return;
    onOpenPlayer();
  }

  Future<void> _playTrack(
    BuildContext context,
    MusicLibraryViewModel vm,
    int index,
  ) async {
    await vm.playAllTrackAt(index);
    if (!context.mounted) return;
    onOpenPlayer();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MusicLibraryViewModel>();
    final tracks = vm.tracks;
    final currentTrack = vm.currentTrack;
    final totalDuration = tracks.fold<Duration>(
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
                              'All Playlist',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Every MP3 on your device, ready to play in one flow.',
                              style: TextStyle(color: AppTheme.textSoft),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Center(
                          child: _PlaylistGlyph(
                            color: Color(0xFF8CE0FF),
                            accent: Color(0xFF1C7DFF),
                            size: 24,
                          ),
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
                          Color(0xFF43C8FF),
                          Color(0xFF1C7DFF),
                          Color(0xFF0E2C68),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3327A2FF),
                          blurRadius: 28,
                          offset: Offset(0, 16),
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
                              child: const _PlaylistGlyph(
                                color: Colors.white,
                                accent: Colors.white,
                                size: 26,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              tracks.isEmpty
                                  ? 'Empty'
                                  : '${tracks.length} tracks',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Your full local library',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tracks.isEmpty
                              ? 'Scan your device to pull every MP3 into one playlist.'
                              : 'Tap any track to start playback and continue through the complete All Playlist queue.',
                          style: const TextStyle(
                            color: Color(0xFFF4FBFF),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _MetricChip(
                              icon: Icons.library_music_rounded,
                              label: '${tracks.length} MP3',
                            ),
                            _MetricChip(
                              icon: Icons.schedule_rounded,
                              label: _formatLargeDuration(tracks),
                            ),
                            _MetricChip(
                              icon: Icons.bolt_rounded,
                              label:
                                  tracks.isEmpty ? 'Scan first' : 'Queue ready',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: tracks.isEmpty
                                    ? null
                                    : () => _playAll(context, vm),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF0F1E39),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text(
                                  'Play all',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.tonalIcon(
                              onPressed:
                                  vm.isLoading ? null : vm.scanDeviceAndSave,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.18),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                              ),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Scan'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (vm.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (vm.error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _MessageCard(
                    title: 'Could not load your library',
                    message: vm.error!,
                  ),
                )
              else if (tracks.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _MessageCard(
                    title: 'No MP3 found yet',
                    message:
                        'Tap Scan to read every MP3 on your device and build your All Playlist automatically.',
                    action: FilledButton.icon(
                      onPressed: vm.scanDeviceAndSave,
                      icon: const Icon(Icons.folder_open_rounded),
                      label: const Text('Scan device'),
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 14),
                    child: Row(
                      children: [
                        const Text(
                          'All tracks',
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
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
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
                                      ? const Color(0xFF43C8FF)
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
                                              ? const Color(0xFF43C8FF)
                                              : const Color(0xFF1C7DFF),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Icon(
                                          isCurrent && vm.isPlaying
                                              ? Icons.graphic_eq_rounded
                                              : Icons.play_arrow_rounded,
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
                                                      const Color(0xFF203655),
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
                                                    color: Color(0xFF9BE9FF),
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
                                              'All playlist #${index + 1}',
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

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String title;
  final String message;
  final Widget? action;

  const _MessageCard({
    required this.title,
    required this.message,
    this.action,
  });

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
                    colors: [Color(0xFF43C8FF), Color(0xFF1C7DFF)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: _PlaylistGlyph(
                    color: Colors.white,
                    accent: Colors.white,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSoft,
                  height: 1.5,
                ),
              ),
              if (action != null) ...[
                const SizedBox(height: 18),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaylistGlyph extends StatelessWidget {
  final Color color;
  final Color accent;
  final double size;

  const _PlaylistGlyph({
    required this.color,
    required this.accent,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PlaylistGlyphPainter(
          color: color,
          accent: accent,
        ),
      ),
    );
  }
}

class _PlaylistGlyphPainter extends CustomPainter {
  final Color color;
  final Color accent;

  const _PlaylistGlyphPainter({
    required this.color,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.11;

    final accentPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;

    final topY = size.height * 0.28;
    final midY = size.height * 0.5;
    final bottomY = size.height * 0.72;
    final startX = size.width * 0.14;
    final endX = size.width * 0.82;

    canvas.drawLine(Offset(startX, topY), Offset(endX, topY), linePaint);
    canvas.drawLine(Offset(startX, midY), Offset(endX, midY), linePaint);
    canvas.drawLine(
        Offset(startX, bottomY), Offset(endX * 0.82, bottomY), linePaint);

    canvas.drawCircle(
      Offset(size.width * 0.84, bottomY),
      size.width * 0.12,
      accentPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.84, bottomY),
      size.width * 0.06,
      Paint()..color = const Color(0xFF0B1424),
    );
  }

  @override
  bool shouldRepaint(covariant _PlaylistGlyphPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.accent != accent;
  }
}
