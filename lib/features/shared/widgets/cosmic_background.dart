import 'package:flutter/material.dart';
import 'dart:math' as math;

class CosmicBackground extends StatefulWidget {
  const CosmicBackground({Key? key}) : super(key: key);

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 3),
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: CosmicPainter(
            animationValue: _controller.value,
          ),
          size: Size.infinite,
          child: Container(),
        );
      },
    );
  }
}

class CosmicPainter extends CustomPainter {
  final double animationValue;
  final Random _random = Random(42); // Fixed seed for consistent star positions
  final List<Star> _stars = [];
  final int _starCount = 150;

  CosmicPainter({required this.animationValue}) {
    // Initialize stars if not already done
    if (_stars.isEmpty) {
      for (int i = 0; i < _starCount; i++) {
        _stars.add(Star(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 2.5 + 0.5,
          twinkleSpeed: _random.nextDouble() * 2 + 1,
          twinkleOffset: _random.nextDouble() * math.pi * 2,
        ));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Soft Celestial backdrop — a gentle light pastel sky.
    final Paint backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFBF7FF), // pastel sky (lightBackground)
          Color(0xFFF3ECFB), // soft lavender wash (surfaceMuted)
          Color(0xFFFFF7EC), // warm cream
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Draw soft pastel / gold star specks
    for (var star in _stars) {
      final starX = star.x * size.width;
      final starY = star.y * size.height;

      // Calculate twinkle effect
      final twinkle = (math.sin((animationValue * star.twinkleSpeed * 10) + star.twinkleOffset) + 1) / 2;
      // Gentle, low-opacity specks so they read as subtle sparkle on light.
      final starOpacity = 0.12 + (twinkle * 0.28);
      final starSize = star.size * (0.7 + (twinkle * 0.3));

      // Alternate between soft gold and lavender specks.
      final speckColor = star.twinkleSpeed > 2
          ? const Color(0xFFF2C879) // soft gold star
          : const Color(0xFF8B6FE0); // soft lavender

      final starPaint = Paint()
        ..color = speckColor.withValues(alpha: starOpacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(starX, starY), starSize, starPaint);

      // Draw a tender glow for larger specks.
      if (star.size > 1.5) {
        final glowPaint = Paint()
          ..color = speckColor.withValues(alpha: starOpacity * 0.4)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

        canvas.drawCircle(Offset(starX, starY), starSize * 2, glowPaint);
      }
    }

    // Draw soft pastel aura clouds
    _drawNebula(canvas, size, animationValue);
  }

  void _drawNebula(Canvas canvas, Size size, double animationValue) {
    // Soft pastel aura clouds — gentle peach / lavender / mint / sky blooms.
    final nebulaColors = [
      const Color(0x14CDB7FF), // lavender
      const Color(0x14FFD7C2), // peach
      const Color(0x14C8F2DC), // mint
      const Color(0x14BEE8FF), // sky blue
    ];

    for (int i = 0; i < 4; i++) {
      final centerX = size.width * (0.2 + (i * 0.2));
      final centerY = size.height * (0.3 + (math.sin(animationValue * 0.5 + i) * 0.1));
      final radius = size.width * 0.3;

      final nebulaPaint = Paint()
        ..color = nebulaColors[i]
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50.0);

      canvas.drawCircle(Offset(centerX, centerY), radius, nebulaPaint);
    }
  }

  @override
  bool shouldRepaint(CosmicPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double twinkleSpeed;
  final double twinkleOffset;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleSpeed,
    required this.twinkleOffset,
  });
}

class Random {
  final math.Random _random;
  
  Random(int seed) : _random = math.Random(seed);
  
  double nextDouble() {
    return _random.nextDouble();
  }
} 