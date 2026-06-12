import 'package:flutter/material.dart';
import 'package:push_notes/screens/home_screen.dart';

class CRTSplashScreen extends StatefulWidget {
  const CRTSplashScreen({super.key});

  @override
  State<CRTSplashScreen> createState() => _CRTSplashScreenState();
}

class _CRTSplashScreenState extends State<CRTSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() => _done = true);
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _done
          ? const MyHomePage(key: ValueKey('home'))
          : _buildSplash(),
    );
  }

  Widget _buildSplash() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final progress = _animation.value;
          final scanOpacity = (1.0 - progress * 1.3).clamp(0.0, 1.0);
          final glowOpacity = (progress * 0.4).clamp(0.0, 0.4);

          return Stack(
            children: [
              Center(
                child: Opacity(
                  opacity: progress.clamp(0.0, 1.0),
                  child: const Text(
                    '_Notes',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
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
      ),
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

    const lineCount = 80;
    final lineHeight = size.height / lineCount;

    if (scanOpacity > 0) {
      final paint = Paint()..color = Colors.black.withValues(alpha: scanOpacity);
      for (int i = 0; i < lineCount; i += 2) {
        canvas.drawRect(
          Rect.fromLTWH(0, i * lineHeight, size.width, lineHeight),
          paint,
        );
      }
    }

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
