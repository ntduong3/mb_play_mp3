import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _BottomNavItemData(
        label: 'Home',
        icon: Icons.home_rounded,
        accent: Color(0xFF6FE6FF),
      ),
      _BottomNavItemData(
        label: 'Search',
        icon: Icons.search_rounded,
        accent: Color(0xFF8A9CFF),
      ),
      _BottomNavItemData(
        label: 'All',
        accent: Color(0xFF43C8FF),
        usePlaylistGlyph: true,
      ),
      _BottomNavItemData(
        label: 'Liked',
        icon: Icons.favorite_rounded,
        accent: Color(0xFFFF7A8A),
      ),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF18283F), Color(0xFF101A2B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x45030B16),
              blurRadius: 26,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = currentIndex == index;
              return Expanded(
                child: _BottomNavButton(
                  item: item,
                  selected: selected,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  final _BottomNavItemData item;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: selected
            ? LinearGradient(
                colors: [
                  item.accent.withOpacity(0.26),
                  const Color(0x22FFFFFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected
                        ? item.accent.withOpacity(0.18)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? item.accent.withOpacity(0.35)
                          : Colors.white10,
                    ),
                  ),
                  child: Center(
                    child: item.usePlaylistGlyph
                        ? _PlaylistTabIcon(
                            color: selected ? item.accent : Colors.white70,
                            size: 20,
                          )
                        : Icon(
                            item.icon,
                            size: 22,
                            color: selected ? item.accent : Colors.white70,
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : Colors.white54,
                    letterSpacing: 0.2,
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItemData {
  final String label;
  final IconData icon;
  final Color accent;
  final bool usePlaylistGlyph;

  const _BottomNavItemData({
    required this.label,
    this.icon = Icons.circle,
    required this.accent,
    this.usePlaylistGlyph = false,
  });
}

class _PlaylistTabIcon extends StatelessWidget {
  final Color color;
  final double size;

  const _PlaylistTabIcon({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PlaylistTabIconPainter(color: color),
      ),
    );
  }
}

class _PlaylistTabIconPainter extends CustomPainter {
  final Color color;

  const _PlaylistTabIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final startX = size.width * 0.16;
    final endX = size.width * 0.78;
    final topY = size.height * 0.28;
    final midY = size.height * 0.5;
    final bottomY = size.height * 0.72;

    canvas.drawLine(Offset(startX, topY), Offset(endX, topY), stroke);
    canvas.drawLine(Offset(startX, midY), Offset(endX, midY), stroke);
    canvas.drawLine(
      Offset(startX, bottomY),
      Offset(size.width * 0.62, bottomY),
      stroke,
    );

    canvas.drawCircle(
        Offset(size.width * 0.8, bottomY), size.width * 0.14, fill);
    canvas.drawCircle(
      Offset(size.width * 0.8, bottomY),
      size.width * 0.07,
      Paint()..color = const Color(0xFF101A2B),
    );
  }

  @override
  bool shouldRepaint(covariant _PlaylistTabIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
