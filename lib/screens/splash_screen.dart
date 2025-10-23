import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _progressController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Glow effect controller
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Particle animation controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Progress bar controller
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Setup animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    // Start animations
    _mainController.forward();
    _progressController.forward();

    // Navigate to login screen after animation
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Get.offNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // White background
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
          ),

          // Particle/Grid effect background
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particleController.value),
                child: Container(),
              );
            },
          ),

          // Main content
          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // Logo with glow effect
                      Transform.translate(
                        offset: Offset(0, -_slideAnimation.value),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: AnimatedBuilder(
                              animation: _glowController,
                              builder: (context, child) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      // Multiple glow layers
                                      BoxShadow(
                                        color: Colors.cyan.withValues(
                                          alpha: 0.6 * _glowAnimation.value,
                                        ),
                                        blurRadius: 40 * _glowAnimation.value,
                                        spreadRadius: 5 * _glowAnimation.value,
                                      ),
                                      BoxShadow(
                                        color: Colors.blue.withValues(
                                          alpha: 0.4 * _glowAnimation.value,
                                        ),
                                        blurRadius: 60 * _glowAnimation.value,
                                        spreadRadius: 10 * _glowAnimation.value,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'lib/assets/images/logo.jpg',
                                      width: 160,
                                      height: 160,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 40 - _slideAnimation.value * 0.5),

                      // App name with futuristic style
                      Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 0.5),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              // Main title
                              Text(
                                'MAN\'S CHOICE',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 6,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Subtitle
                              Text(
                                'ENTERPRISE',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 8,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Animated divider
                              AnimatedBuilder(
                                animation: _mainController,
                                builder: (context, child) {
                                  return Container(
                                    height: 2,
                                    width: 150 * _scaleAnimation.value,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 20),

                              // Tagline
                              Text(
                                '"Aiming the future, Together"',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                  letterSpacing: 1,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // System label with tech styling
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'CREDIT MANAGEMENT SYSTEM',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Futuristic loading bar
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60),
                          child: Column(
                            children: [
                              // Loading text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock_clock,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'INITIALIZING SYSTEM',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Progress bar
                              AnimatedBuilder(
                                animation: _progressController,
                                builder: (context, child) {
                                  return Stack(
                                    children: [
                                      // Background track
                                      Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      // Progress
                                      FractionallySizedBox(
                                        widthFactor: _progressController.value,
                                        child: Container(
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 12),

                              // Percentage
                              AnimatedBuilder(
                                animation: _progressController,
                                builder: (context, child) {
                                  return Text(
                                    '${(_progressController.value * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Version info
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'v1.0.0 • POWERED BY INNOVATION',
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for particle/grid effect
class ParticlePainter extends CustomPainter {
  final double animationValue;
  final Random random = Random(42); // Fixed seed for consistent pattern

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    // Draw moving particles with subtle colors for white background
    for (int i = 0; i < 50; i++) {
      final x = (random.nextDouble() * size.width + animationValue * 50) % size.width;
      final y = (random.nextDouble() * size.height + animationValue * 30) % size.height;
      final opacity = 0.05 + random.nextDouble() * 0.1;

      paint.color = Colors.blue.withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(x, y),
        1 + random.nextDouble() * 2,
        paint,
      );
    }

    // Draw subtle grid lines
    paint
      ..color = Colors.grey.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke;

    // Horizontal lines
    for (int i = 0; i < 10; i++) {
      final y = (size.height / 10) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Vertical lines
    for (int i = 0; i < 10; i++) {
      final x = (size.width / 10) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}
