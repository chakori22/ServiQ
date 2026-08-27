import 'dart:math';
import 'package:flutter/material.dart';

/// Animated splash screen shown on app launch.
/// - Logo bounces/scales in with an elastic curve
/// - Tagline fades + slides up shortly after
/// - A few service icons gently float in the background for visual interest
/// - Bottom wave matches the Home screen's header shape for continuity
/// - Auto-navigates to [nextScreen] after the animation completes
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.nextScreen});

  final Widget nextScreen;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _floatController;
  late final AnimationController _exitController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _exitOpacity;

  static const Color primaryBlue = Color(0xFF1E6FD9);
  static const Color darkBlue = Color(0xFF0B4FA8);

  final List<IconData> _floatingIcons = const [
    Icons.bolt,
    Icons.water_drop,
    Icons.handyman,
    Icons.build,
    Icons.cleaning_services,
  ];

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Continuous slow float loop for the background icons — purely decorative.
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Fades the ENTIRE splash screen (logo, text, wave, everything) to
    // fully transparent before we navigate away, so nothing from this
    // screen is still on-screen when the next route appears — that
    // overlap is what was causing the wave to flash after navigation.
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _exitOpacity = CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeOut,
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await _logoController.forward();
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    // Fade the whole splash out completely first...
    await _exitController.forward();
    if (!mounted) return;

    // ...then swap screens with NO further transition animation, since
    // the splash is already invisible — no two screens are ever
    // rendered on top of each other at once.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            widget.nextScreen,
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _floatController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: FadeTransition(
        // Inverted: exitController goes 0 -> 1 while fading OUT, so we
        // flip it here to drive opacity from 1 -> 0.
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_exitOpacity),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryBlue, darkBlue],
            ),
          ),
          child: Stack(
            children: [
              // Floating decorative service icons
              ..._buildFloatingIcons(size),

              // Center content: logo + tagline
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.handyman_rounded,
                            size: 52,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Column(
                          children: const [
                            Text(
                              'ServiQ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Real-time help, right around the corner.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeTransition(
                      opacity: _textOpacity,
                      child: const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom wave, matching the Home screen header shape
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipPath(
                  clipper: _WaveClipper(),
                  child: Container(height: 60, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFloatingIcons(Size size) {
    final random = Random(7); // fixed seed so layout is stable across builds
    return List.generate(_floatingIcons.length, (index) {
      final startTop = random.nextDouble() * size.height * 0.7 + 40;
      final left = random.nextDouble() * (size.width - 60) + 10;
      final iconSize = 22.0 + random.nextInt(14);
      final phaseOffset = index / _floatingIcons.length;

      return AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final t = (_floatController.value + phaseOffset) % 1.0;
          final dy = sin(t * 2 * pi) * 12;
          return Positioned(
            top: startTop + dy,
            left: left,
            child: Opacity(
              opacity: 0.18,
              child: Icon(
                _floatingIcons[index],
                size: iconSize,
                color: Colors.white,
              ),
            ),
          );
        },
      );
    });
  }
}

/// Wave clipper matching the curved bottom edge used on the Home screen header.
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 20);
    path.quadraticBezierTo(size.width * 0.25, 60, size.width * 0.5, 25);
    path.quadraticBezierTo(size.width * 0.75, -10, size.width, 30);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
