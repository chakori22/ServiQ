import 'dart:math';
import 'package:flutter/material.dart';

/// Animated splash screen shown on app launch.
/// - Logo bounces/scales in with an elastic curve
/// - Tagline fades + slides up shortly after
/// - A few service icons gently float in the background for visual interest
/// - Bottom wave matches the Home screen's header shape for continuity
/// - Remains visible while the app is initialized; [ServiqApp] performs the
///   eventual navigation to its configured target location.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _floatController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

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
    print("Splash Screen");

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

    _startSequence();
  }

  Future<void> _startSequence() async {
    await _logoController.forward();
    await _textController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.ltr,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
