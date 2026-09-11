import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Soft two-tone gradients used for hero banners and placeholder tiles.
class EbGradients {
  const EbGradients._();

  static const List<List<Color>> _palettes = [
    [Color(0xFFF7E8EA), Color(0xFFEFD3DA)], // blush
    [Color(0xFFEFF3EC), Color(0xFFD8E3D2)], // sage
    [Color(0xFFFDF6E9), Color(0xFFF3E4C4)], // cream/gold
    [Color(0xFFEFEAF6), Color(0xFFDCCFEA)], // lilac
    [Color(0xFFEAF2F6), Color(0xFFD2E2EA)], // sky
  ];

  static LinearGradient bySeed(int seed, {AlignmentGeometry? begin, AlignmentGeometry? end}) {
    final palette = _palettes[seed.abs() % _palettes.length];
    final angle = (seed % 4) * math.pi / 8 + math.pi / 6;
    return LinearGradient(
      colors: palette,
      begin: Alignment(math.cos(angle), -math.sin(angle)),
      end: Alignment(-math.cos(angle), math.sin(angle)),
    );
  }

  static const LinearGradient blushHero = LinearGradient(
    colors: [Color(0xFFF7E8EA), Color(0xFFFDFBF7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldSheen = LinearGradient(
    colors: [Color(0xFFD9BC85), Color(0xFFB08D4E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sageVeil = LinearGradient(
    colors: [Color(0xFFA8BCA1), Color(0xFF7C9574)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Deterministic gradient placeholder for clinic/treatment imagery.
class EbGradientPlaceholder extends StatelessWidget {
  const EbGradientPlaceholder({
    super.key,
    required this.seed,
    this.icon = Icons.spa_outlined,
    this.iconSize = 40,
    this.borderRadius = BorderRadius.zero,
  });

  final int seed;
  final IconData icon;
  final double iconSize;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: EbGradients.bySeed(seed),
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: iconSize,
        color: Colors.white.withValues(alpha: 0.85),
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}
