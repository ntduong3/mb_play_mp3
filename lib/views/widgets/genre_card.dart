import 'package:flutter/material.dart';

class GenreCard extends StatelessWidget {
  final String title;
  final List<Color> colors;
  final String? imagePath;

  const GenreCard({
    super.key,
    required this.title,
    required this.colors,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            if (imagePath != null)
              Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  imagePath!,
                  fit: BoxFit.cover,
                  width: 220,
                  height: double.infinity,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}