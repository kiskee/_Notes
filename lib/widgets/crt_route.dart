import 'package:flutter/material.dart';

class CRTPageRoute extends PageRouteBuilder {
  CRTPageRoute({required Widget page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return CRTTransition(animation: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 400),
        );
}

class CRTTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const CRTTransition({super.key, required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        final scanOpacity = (1.0 - progress * 1.5).clamp(0.0, 1.0);
        final glowOpacity = (progress * 0.3).clamp(0.0, 0.3);

        return Stack(
          children: [
            child!,
            // scan lines overlay
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _CRTPainter(
                    scanOpacity: scanOpacity,
                    glowOpacity: glowOpacity,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}

class _CRTPainter extends CustomPainter {
  final double scanOpacity;
  final double glowOpacity;

  _CRTPainter({required this.scanOpacity, required this.glowOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    if (scanOpacity <= 0 && glowOpacity <= 0) return;

    final lineCount = 80;
    final lineHeight = size.height / lineCount;

    // scan lines
    if (scanOpacity > 0) {
      final paint = Paint()..color = Colors.black.withValues(alpha: scanOpacity);
      for (int i = 0; i < lineCount; i += 2) {
        canvas.drawRect(
          Rect.fromLTWH(0, i * lineHeight, size.width, lineHeight),
          paint,
        );
      }
    }

    // subtle top glow (CRT warm-up)
    if (glowOpacity > 0) {
      final glowPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: glowOpacity * 0.2),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size);
      canvas.drawRect(Offset.zero & size, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_CRTPainter old) =>
      old.scanOpacity != scanOpacity || old.glowOpacity != glowOpacity;
}
