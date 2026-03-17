import 'package:flutter/material.dart';

class MiniPlayer extends StatelessWidget {
  final String title;
  final String artist;
  final String? coverPath;
  final VoidCallback? onPlay;

  const MiniPlayer({
    super.key,
    required this.title,
    required this.artist,
    this.coverPath,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFF2A3342),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF38D7FF), Color(0xFF1C7DFF)],
              ),
            ),
            child: coverPath == null
                ? null
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(coverPath!, fit: BoxFit.cover),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  artist,
                  style: const TextStyle(
                    color: Color(0xFFB7C3D7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onPlay,
            icon: const Icon(Icons.skip_previous_rounded),
          ),
          IconButton(
            onPressed: onPlay,
            icon: const Icon(Icons.pause_rounded, color: Color(0xFF37C8FF)),
          ),
          IconButton(
            onPressed: onPlay,
            icon: const Icon(Icons.skip_next_rounded),
          ),
        ],
      ),
    );
  }
}