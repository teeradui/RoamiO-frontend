import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedRoamiOLogo extends StatefulWidget {
  const AnimatedRoamiOLogo({super.key, this.width = 120, this.height = 130});

  final double width;
  final double height;

  @override
  State<AnimatedRoamiOLogo> createState() => _AnimatedRoamiOLogoState();
}

class _AnimatedRoamiOLogoState extends State<AnimatedRoamiOLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final rotation = _controller.value * 2 * math.pi;

          final float = math.sin(rotation) * 2;
          final scale = 1.0 + math.sin(rotation) * 0.025;

          final impact = (math.sin(rotation) + 1) / 2;

          final circleScaleX = 0.94 + (impact * 0.12);
          final circleScaleY = 1.02 - (impact * 0.08);

          return Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // ✨ Sparkle 1
              _buildSparkle(x: 22, y: 76, size: 7, phase: 0, distance: 8),

              // ✨ Sparkle 2
              _buildSparkle(x: 82, y: 88, size: 5, phase: 1.8, distance: 7),

              // ✨ Sparkle 3
              _buildSparkle(x: 34, y: 104, size: 4, phase: 3.2, distance: 6),

              // ✨ Sparkle 4
              _buildSparkle(x: 92, y: 62, size: 6, phase: 4.5, distance: 8),

              // Circle
              Positioned(
                bottom: 3,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(circleScaleX, circleScaleY),
                  child: Image.asset(
                    'assets/logo/circle.png',
                    width: 72,
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Pin
              Positioned(
                bottom: 30 + float,
                child: Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0018)
                    ..rotateY(rotation)
                    ..rotateX(math.sin(rotation) * 0.08),
                  child: Transform.scale(
                    scale: scale,
                    child: Image.asset(
                      'assets/logo/pin.png',
                      width: 62,
                      height: 82,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSparkle({
    required double x,
    required double y,
    required double size,
    required double phase,
    required double distance,
  }) {
    final progress = (_controller.value * 2 * math.pi + phase) % (2 * math.pi);

    // 0 → 1 → 0
    final life = (math.sin(progress) + 1) / 2;

    final opacity = life * 0.9;

    final scale = 0.35 + life * 0.65;

    final moveX = math.cos(progress) * distance;
    final moveY = math.sin(progress) * distance;

    return Positioned(
      left: x + moveX,
      bottom: y + moveY,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: _Sparkle(size: size),
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SparklePainter()),
    );
  }
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF7050)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    final path = Path();

    path.moveTo(center.dx, 0);
    path.quadraticBezierTo(
      center.dx + size.width * 0.18,
      center.dy - size.height * 0.18,
      size.width,
      center.dy,
    );
    path.quadraticBezierTo(
      center.dx + size.width * 0.18,
      center.dy + size.height * 0.18,
      center.dx,
      size.height,
    );
    path.quadraticBezierTo(
      center.dx - size.width * 0.18,
      center.dy + size.height * 0.18,
      0,
      center.dy,
    );
    path.quadraticBezierTo(
      center.dx - size.width * 0.18,
      center.dy - size.height * 0.18,
      center.dx,
      0,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
