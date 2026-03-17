import 'package:flutter/material.dart';

class CoverArt extends StatelessWidget {
  final double size;
  final double radius;
  final List<Color> colors;
  final String? imagePath;

  const CoverArt({
    super.key,
    required this.size,
    this.radius = 24,
    this.colors = const [Color(0xFF0F2E5C), Color(0xFF2B8CFF)],
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(radius);

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: border,
        gradient: imagePath == null
            ? LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: border,
        child: imagePath == null
            ? Center(
                child: Container(
                  height: size * 0.55,
                  width: size * 0.55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                    gradient: const RadialGradient(
                      colors: [Color(0xFF44D4FF), Color(0xFF1C7DFF)],
                    ),
                  ),
                ),
              )
            : Image.asset(
                imagePath!,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}