import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Connect with Friends',
      description: 'Share moments and stay connected with people you care about',
      icon: Icons.people_outline,
      color: AppColors.primary,
    ),
    OnboardingData(
      title: 'Share Your Story',
      description: 'Express yourself through photos, videos, and stories',
      icon: Icons.camera_alt_outlined,
      color: AppColors.secondary,
    ),
    OnboardingData(
      title: 'Discover Content',
      description: 'Explore trending content and discover new interests',
      icon: Icons.explore_outlined,
      color: AppColors.info,
    ),
    OnboardingData(
      title: 'Stay Safe',
      description: 'AI-powered moderation keeps your experience positive',
      icon: Icons.security,
      color: AppColors.success,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 48 : 16,
              ),
              child: Column(
                children: [
                  _buildTopBar(isTablet),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) => setState(() => _currentPage = index),
                      itemCount: _pages.length,
                      itemBuilder: (context, index) => _buildPage(_pages[index], isTablet),
                    ),
                  ),
                  _buildBottomSection(isTablet),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
            child: Text(
              'Smart Social',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20 : 16,
              vertical: isTablet ? 12 : 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              border: Border.all(color: AppColors.border),
            ),
            child: InkWell(
              onTap: _skipOnboarding,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 48 : 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? 280 : 220,
            height: isTablet ? 280 : 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [data.color, data.color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: data.color.withOpacity(0.25),
                  blurRadius: isTablet ? 40 : 30,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: data.color.withOpacity(0.1),
                  blurRadius: isTablet ? 60 : 50,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Icon(
              data.icon,
              size: isTablet ? 100 : 80,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isTablet ? 80 : 60),
          Text(
            data.title,
            style: TextStyle(
              fontSize: isTablet ? 36 : 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 28 : 20),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 16,
            ),
            child: Text(
              data.description,
              style: TextStyle(
                fontSize: isTablet ? 20 : 16,
                color: AppColors.textSecondary,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 48 : 32),
      child: Column(
        children: [
          _buildPageIndicator(isTablet),
          SizedBox(height: isTablet ? 40 : 32),
          _buildActionButton(isTablet),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: isTablet ? 6 : 4),
          width: _currentPage == index ? (isTablet ? 32 : 24) : (isTablet ? 12 : 8),
          height: isTablet ? 12 : 8,
          decoration: BoxDecoration(
            gradient: _currentPage == index ? AppColors.primaryGradient : null,
            color: _currentPage == index ? null : AppColors.border,
            borderRadius: BorderRadius.circular(isTablet ? 6 : 4),
            boxShadow: _currentPage == index ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: isTablet ? 8 : 6,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(bool isTablet) {
    final isLastPage = _currentPage == _pages.length - 1;
    
    return Container(
      width: double.infinity,
      height: isTablet ? 64 : 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: isTablet ? 20 : 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          onTap: isLastPage ? _completeOnboarding : _nextPage,
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLastPage ? 'Get Started' : 'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                if (!isLastPage) ...[
                  SizedBox(width: isTablet ? 12 : 8),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: isTablet ? 24 : 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipOnboarding() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _completeOnboarding() {
    Navigator.pushReplacementNamed(context, '/login');
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}