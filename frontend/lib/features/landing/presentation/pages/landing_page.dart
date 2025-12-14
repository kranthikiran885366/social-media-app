import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _slideController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 500), () => _slideController.forward());
    
    // Auto-navigate to login after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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
            child: SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 64 : 24,
                        vertical: isTablet ? 40 : 20,
                      ),
                      child: Column(
                        children: [
                          // Logo and Title Section
                          Expanded(
                            flex: 2,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: isTablet ? 160 : 120,
                                    height: isTablet ? 160 : 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.2),
                                          blurRadius: isTablet ? 30 : 20,
                                          spreadRadius: isTablet ? 8 : 5,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome,
                                      size: isTablet ? 80 : 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: isTablet ? 32 : 24),
                                  Text(
                                    'Smart Social',
                                    style: TextStyle(
                                      fontSize: isTablet ? 48 : 36,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: isTablet ? 16 : 12),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 48 : 32,
                                    ),
                                    child: Text(
                                      'Meaningful connections, mindful scrolling',
                                      style: TextStyle(
                                        fontSize: isTablet ? 20 : 16,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Features Section
                          Expanded(
                            flex: 3,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildFeatureItem(
                                    Icons.psychology_outlined,
                                    'AI-Powered Content',
                                    'Only quality content reaches your feed',
                                    isTablet,
                                  ),
                                  SizedBox(height: isTablet ? 20 : 16),
                                  _buildFeatureItem(
                                    Icons.timer_outlined,
                                    'Time Management',
                                    'Stay productive with smart limits',
                                    isTablet,
                                  ),
                                  SizedBox(height: isTablet ? 20 : 16),
                                  _buildFeatureItem(
                                    Icons.verified_user_outlined,
                                    'Meaningful Connections',
                                    'Connect with purpose and authenticity',
                                    isTablet,
                                  ),
                                  SizedBox(height: isTablet ? 48 : 40),
                                  _buildActionButton(
                                    'Get Started',
                                    () => context.go('/register'),
                                    true,
                                    isTablet,
                                  ),
                                  SizedBox(height: isTablet ? 16 : 12),
                                  _buildActionButton(
                                    'Sign In',
                                    () => context.go('/login'),
                                    false,
                                    isTablet,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: isTablet ? 15 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 56 : 48,
            height: isTablet ? 56 : 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isTablet ? 28 : 24,
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: isTablet ? 18 : 16,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isTablet ? 15 : 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, bool isPrimary, bool isTablet) {
    return Container(
      width: double.infinity,
      height: isTablet ? 64 : 56,
      decoration: BoxDecoration(
        gradient: isPrimary ? LinearGradient(
          colors: [Colors.white, Colors.white.withOpacity(0.95)],
        ) : null,
        color: isPrimary ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: isPrimary ? null : Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 2,
        ),
        boxShadow: isPrimary ? [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: isTablet ? 20 : 15,
            offset: const Offset(0, 8),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          onTap: onPressed,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w700,
                color: isPrimary ? AppColors.primary : Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}