import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/music_library_viewmodel.dart';
import 'widgets/app_background.dart';

class MusicQueuePage extends StatelessWidget {
  const MusicQueuePage({super.key});

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MusicLibraryViewModel>();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vm.activeQueueLabel,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${vm.queue.length} tracks in current list',
                            style: const TextStyle(color: Color(0xFF97A5BE)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: vm.isLoading ? null : vm.scanDeviceAndSave,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1D2B3F), Color(0xFF152030)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C7DFF),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.queue_music_rounded,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vm.currentTrack?.title ??
                                  'Choose a track to play',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vm.queue.isEmpty
                                  ? 'No track available in this list yet'
                                  : 'Current position ${vm.currentIndex + 1}/${vm.queue.length}',
                              style: const TextStyle(color: Color(0xFF97A5BE)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.error != null
                        ? Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                vm.error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          )
                        : vm.queue.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Text(
                                    'No songs inside ${vm.activeQueueLabel} yet.',
                                    textAlign: TextAlign.center,
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 24),
                                itemCount: vm.queue.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final track = vm.queue[index];
                                  final isCurrent =
                                      vm.currentTrack?.id == track.id;
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(22),
                                      onTap: () async {
                                        await vm.playAtIndex(index);
                                        if (!context.mounted) return;
                                        Navigator.of(context).pop();
                                      },
                                      child: Ink(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: isCurrent
                                              ? const Color(0xFF1B3150)
                                              : const Color(0xFF121B27),
                                          borderRadius:
                                              BorderRadius.circular(22),
                                          border: Border.all(
                                            color: isCurrent
                                                ? const Color(0xFF37C8FF)
                                                : Colors.white10,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 52,
                                              height: 52,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                gradient: LinearGradient(
                                                  colors: isCurrent
                                                      ? const [
                                                          Color(0xFF37C8FF),
                                                          Color(0xFF1C7DFF)
                                                        ]
                                                      : const [
                                                          Color(0xFF2A3648),
                                                          Color(0xFF1C2432)
                                                        ],
                                                ),
                                              ),
                                              child: Icon(
                                                isCurrent && vm.isPlaying
                                                    ? Icons.graphic_eq_rounded
                                                    : Icons.music_note_rounded,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    track.title,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    track.artist,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0xFF97A5BE)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  _formatDuration(Duration(
                                                      milliseconds:
                                                          track.durationMs)),
                                                  style: const TextStyle(
                                                    color: Color(0xFFE7EEF9),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  '#${index + 1}',
                                                  style: const TextStyle(
                                                      color: Color(0xFF97A5BE),
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
