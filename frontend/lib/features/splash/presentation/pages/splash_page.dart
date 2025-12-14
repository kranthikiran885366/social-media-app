import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    _textController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _particleController = AnimationController(duration: const Duration(milliseconds: 3000), vsync: this);
    
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    _particleController.repeat();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();
    
    await Future.delayed(const Duration(milliseconds: 2500));
    _navigateToNext();
  }

  void _navigateToNext() {
    // Check if user is logged in, show appropriate page
    context.go('/landing');
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Stack(
              children: [
                _buildParticles(),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 64 : 32,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: _logoAnimation,
                          child: RotationTransition(
                            turns: _rotationAnimation,
                            child: Container(
                              width: isTablet ? 180 : 140,
                              height: isTablet ? 180 : 140,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.25),
                                    blurRadius: isTablet ? 40 : 30,
                                    spreadRadius: isTablet ? 8 : 5,
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: EdgeInsets.all(isTablet ? 28 : 20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.auto_awesome,
                                  size: isTablet ? 80 : 60,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isTablet ? 56 : 40),
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(_textAnimation),
                          child: FadeTransition(
                            opacity: _textAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'Smart Social',
                                  style: TextStyle(
                                    fontSize: isTablet ? 48 : 38,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -1.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: isTablet ? 20 : 16),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 24 : 20,
                                    vertical: isTablet ? 12 : 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'AI-Powered Social Experience',
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      color: Colors.white.withOpacity(0.95),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (index) {
            final double animationValue = (_particleAnimation.value + index * 0.1) % 1.0;
            final double size = 4 + (index % 3) * 2;
            final double left = (index * 50.0) % MediaQuery.of(context).size.width;
            final double top = MediaQuery.of(context).size.height * animationValue;
            
            return Positioned(
              left: left,
              top: top,
              child: Opacity(
                opacity: 0.6 - animationValue * 0.6,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}