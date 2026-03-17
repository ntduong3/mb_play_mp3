import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/music_track.dart';
import '../viewmodels/music_library_viewmodel.dart';
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
  bool _isPlaying = true;
  bool _isFavorite = false;
  bool _isShuffle = false;
  bool _isRepeat = false;
  double _progress = 0.38;
  MusicTrack? _currentTrack;
  int? _currentIndex;

  static const int _totalSeconds = 6 * 60 + 22;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    final vm = context.read<MusicLibraryViewModel>();
    vm.loadLocalLibrary().then((_) {
      if (vm.tracks.isEmpty) {
        vm.scanDeviceAndSave();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remain = seconds % 60;
    final padded = remain.toString().padLeft(2, '0');
    return '$minutes:$padded';
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

  void _maybeInitCurrentTrack(MusicLibraryViewModel vm) {
    if (vm.tracks.isEmpty) return;
    if (_currentIndex != null && _currentIndex! < vm.tracks.length) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _currentIndex = 0;
        _currentTrack = vm.tracks.first;
        _isPlaying = false;
        _progress = 0;
      });
    });
  }

  Future<void> _playTrackAt(MusicLibraryViewModel vm, int index) async {
    if (index < 0 || index >= vm.tracks.length) return;
    final track = vm.tracks[index];
    setState(() {
      _currentTrack = track;
      _currentIndex = index;
      _isPlaying = true;
      _progress = 0;
    });
    await vm.play(track);
    _showToast('Ðang phát: ${track.title}');
  }

  Future<void> _playNext(MusicLibraryViewModel vm) async {
    if (vm.tracks.isEmpty) {
      _showToast('Chua có bài d? phát');
      return;
    }

    final current = _currentIndex ?? 0;
    int nextIndex;
    if (_isShuffle && vm.tracks.length > 1) {
      final rand = Random();
      do {
        nextIndex = rand.nextInt(vm.tracks.length);
      } while (nextIndex == current);
    } else {
      nextIndex = (current + 1) % vm.tracks.length;
    }

    await _playTrackAt(vm, nextIndex);
  }

  Future<void> _playPrevious(MusicLibraryViewModel vm) async {
    if (vm.tracks.isEmpty) {
      _showToast('Chua có bài d? phát');
      return;
    }

    final current = _currentIndex ?? 0;
    int prevIndex;
    if (_isShuffle && vm.tracks.length > 1) {
      final rand = Random();
      do {
        prevIndex = rand.nextInt(vm.tracks.length);
      } while (prevIndex == current);
    } else {
      prevIndex = (current - 1 + vm.tracks.length) % vm.tracks.length;
    }

    await _playTrackAt(vm, prevIndex);
  }

  Widget _buildLibraryContent(MusicLibraryViewModel vm, ScrollController controller) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null) {
      return Center(
        child: Text(
          vm.error!,
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (vm.tracks.isEmpty) {
      return const Center(
        child: Text(
          'Chua tìm th?y file .mp3 trên thi?t b?.',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    return ListView.separated(
      controller: controller,
      itemCount: vm.tracks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final track = vm.tracks[index];
        final isCurrent = _currentTrack?.id == track.id;
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          title: Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            track.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF97A5BE)),
          ),
          trailing: isCurrent
              ? const Icon(Icons.graphic_eq_rounded, color: Color(0xFF37C8FF))
              : null,
          onTap: () => _playTrackAt(vm, index),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<MusicLibraryViewModel>();
    final currentSeconds = (_totalSeconds * _progress).round();

    _maybeInitCurrentTrack(vm);

    final title = _currentTrack?.title ?? l10n.nowPlayingSong;
    final artist = _currentTrack?.artist ?? l10n.nowPlayingArtist;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
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
                          onPressed: () => _showToast('Danh sách phát'),
                          icon: const Icon(Icons.queue_music_rounded),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const CoverArt(
                    size: 280,
                    radius: 32,
                    imagePath: 'assets/images/cover_awaken.png',
                  ),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => _isFavorite = !_isFavorite);
                            _showToast(_isFavorite ? 'Ðã thêm yêu thích' : 'Ðã b? yêu thích');
                          },
                          icon: Icon(
                            _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: _isFavorite ? const Color(0xFFFF5D6C) : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        artist,
                        style: const TextStyle(color: Color(0xFF97A5BE), fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Slider(
                          value: _progress,
                          onChanged: (value) => setState(() => _progress = value),
                          activeColor: const Color(0xFF37C8FF),
                          inactiveColor: const Color(0xFF2A3648),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatTime(currentSeconds)),
                            const Text(
                              '6:22',
                              style: TextStyle(color: Color(0xFF97A5BE)),
                            ),
                          ],
                        ),
                      ],
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
                            setState(() => _isShuffle = !_isShuffle);
                            _showToast(_isShuffle ? 'B?t phát ng?u nhiên' : 'T?t phát ng?u nhiên');
                          },
                          icon: Icon(
                            Icons.shuffle_rounded,
                            color: _isShuffle ? const Color(0xFF37C8FF) : Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _playPrevious(vm),
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
                            onPressed: () {
                              if (_isPlaying) {
                                vm.pause();
                                setState(() => _isPlaying = false);
                                _showToast('Ðã t?m d?ng');
                              } else {
                                if (_currentIndex == null && vm.tracks.isNotEmpty) {
                                  _playTrackAt(vm, 0);
                                } else if (_currentTrack != null) {
                                  vm.play(_currentTrack!);
                                  setState(() => _isPlaying = true);
                                  _showToast('Ti?p t?c phát');
                                }
                              }
                            },
                            icon: Icon(
                              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _playNext(vm),
                          icon: const Icon(Icons.skip_next_rounded, size: 32),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => _isRepeat = !_isRepeat);
                            _showToast(_isRepeat ? 'B?t l?p l?i' : 'T?t l?p l?i');
                          },
                          icon: Icon(
                            Icons.repeat_rounded,
                            color: _isRepeat ? const Color(0xFF37C8FF) : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.12,
                minChildSize: 0.10,
                maxChildSize: 0.55,
                builder: (context, controller) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2432),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Nh?c trên thi?t b?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: vm.isLoading ? null : vm.scanDeviceAndSave,
                                icon: const Icon(Icons.refresh_rounded),
                                tooltip: 'Quét nh?c',
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(child: _buildLibraryContent(vm, controller)),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
