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
    // Draw deep space background
    final Paint backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0E0B16),
          Color(0xFF1A1025),
          Color(0xFF2C1B47),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Draw stars
    for (var star in _stars) {
      final starX = star.x * size.width;
      final starY = star.y * size.height;
      
      // Calculate twinkle effect
      final twinkle = (math.sin((animationValue * star.twinkleSpeed * 10) + star.twinkleOffset) + 1) / 2;
      final starOpacity = 0.3 + (twinkle * 0.7);
      final starSize = star.size * (0.7 + (twinkle * 0.3));
      
      final starPaint = Paint()
        ..color = Colors.white.withValues(alpha: starOpacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(starX, starY), starSize, starPaint);
      
      // Draw glow effect for larger stars
      if (star.size > 1.5) {
        final glowPaint = Paint()
          ..color = Colors.white.withValues(alpha: starOpacity * 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

        canvas.drawCircle(Offset(starX, starY), starSize * 2, glowPaint);
      }
    }

    // Draw nebula effects
    _drawNebula(canvas, size, animationValue);
  }

  void _drawNebula(Canvas canvas, Size size, double animationValue) {
    // Draw a few colorful nebula clouds
    final nebulaColors = [
      const Color(0x15A239A3), // Purple
      const Color(0x154B0082), // Indigo
      const Color(0x15FF1493), // Pink
      const Color(0x154169E1), // Blue
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