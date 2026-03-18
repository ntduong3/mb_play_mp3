import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../viewmodels/music_library_viewmodel.dart';
import 'music_queue_page.dart';
import 'widgets/app_background.dart';
import 'widgets/cover_art.dart';

class PlayerPage extends StatefulWidget {
  final VoidCallback onBack;

  const PlayerPage({super.key, required this.onBack});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  bool _didInit = false;
  bool _isFavorite = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    final vm = context.read<MusicLibraryViewModel>();
    if (vm.tracks.isNotEmpty || vm.queue.isNotEmpty || vm.currentTrack != null) {
      return;
    }

    vm.loadLocalLibrary().then((_) {
      if (vm.tracks.isEmpty) {
        vm.scanDeviceAndSave();
      }
    });
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _openAllSongs() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MusicQueuePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<MusicLibraryViewModel>();

    final currentTrack = vm.currentTrack;
    final title = currentTrack?.title ?? l10n.nowPlayingSong;
    final artist = currentTrack?.artist ?? l10n.nowPlayingArtist;
    final totalDuration = vm.currentDuration.inMilliseconds > 0
        ? vm.currentDuration
        : Duration(milliseconds: currentTrack?.durationMs ?? 0);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.chevron_left_rounded, size: 34),
                    ),
                    const Spacer(),
                    Text(
                      l10n.playingNow,
                      style: const TextStyle(
                        letterSpacing: 3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _openAllSongs,
                      icon: const Icon(Icons.queue_music_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const CoverArt(
                size: 280,
                radius: 32,
                imagePath: 'assets/images/cover_awaken.gif',
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF97A5BE),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => _isFavorite = !_isFavorite);
                        _showToast(
                          _isFavorite ? 'Added to favorites' : 'Removed from favorites',
                        );
                      },
                      icon: Icon(
                        _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: _isFavorite ? const Color(0xFFFF5D6C) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _openAllSongs,
                  child: Ink(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17202D),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                vm.queue.isEmpty
                                    ? 'Queue is empty'
                                    : 'Playing queue ${vm.currentIndex + 1}/${vm.queue.length}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF223047),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                totalDuration.inMilliseconds > 0
                                    ? _formatDuration(totalDuration)
                                    : '--:--',
                                style: const TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                          ),
                          child: Slider(
                            value: vm.progress,
                            onChanged: totalDuration.inMilliseconds <= 0
                                ? null
                                : (value) => vm.seekToFraction(value),
                            activeColor: const Color(0xFF37C8FF),
                            inactiveColor: const Color(0xFF2A3648),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(vm.currentPosition)),
                            Text(
                              totalDuration.inMilliseconds > 0
                                  ? _formatDuration(totalDuration)
                                  : '--:--',
                              style: const TextStyle(color: Color(0xFF97A5BE)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF223047),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.library_music_rounded,
                                      size: 16,
                                      color: Color(0xFF37C8FF),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${vm.tracks.length} MP3 songs',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.open_in_new_rounded, color: Color(0xFF97A5BE)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 120),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        vm.toggleShuffle();
                        _showToast(vm.isShuffle ? 'Shuffle on' : 'Shuffle off');
                      },
                      icon: Icon(
                        Icons.shuffle_rounded,
                        color: vm.isShuffle ? const Color(0xFF37C8FF) : Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: vm.queue.isEmpty ? null : vm.playPrevious,
                      icon: const Icon(Icons.skip_previous_rounded, size: 32),
                    ),
                    Container(
                      height: 72,
                      width: 72,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1C7DFF),
                      ),
                      child: IconButton(
                        onPressed: vm.queue.isEmpty
                            ? null
                            : () async {
                                if (vm.isPlaying) {
                                  await vm.pause();
                                  if (!mounted) return;
                                  _showToast('Paused');
                                } else {
                                  await vm.playOrResume();
                                  if (!mounted) return;
                                  _showToast('Playing');
                                }
                              },
                        icon: Icon(
                          vm.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: vm.queue.isEmpty ? null : vm.playNext,
                      icon: const Icon(Icons.skip_next_rounded, size: 32),
                    ),
                    IconButton(
                      onPressed: () {
                        vm.toggleRepeat();
                        _showToast(vm.isRepeat ? 'Repeat on' : 'Repeat off');
                      },
                      icon: Icon(
                        Icons.repeat_rounded,
                        color: vm.isRepeat ? const Color(0xFF37C8FF) : Colors.white,
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
