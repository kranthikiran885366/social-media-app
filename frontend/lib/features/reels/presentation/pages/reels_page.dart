import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: 10,
                itemBuilder: (context, index) => _buildReelItem(index, isTablet),
              ),
              _buildTopBar(isTablet),
              _buildSideActions(isTablet),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReelItem(int index, bool isTablet) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.2),
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: isTablet ? 280 : 220,
              height: isTablet ? 280 : 220,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient.scale(0.3),
                borderRadius: BorderRadius.circular(isTablet ? 32 : 24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: isTablet ? 30 : 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                size: isTablet ? 100 : 80,
                color: Colors.white,
              ),
            ),
          ),
          _buildBottomInfo(index, isTablet),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isTablet) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 12 : 8,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'Reels',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 28 : 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: isTablet ? 28 : 24,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideActions(bool isTablet) {
    return Positioned(
      right: isTablet ? 32 : 16,
      bottom: isTablet ? 140 : 100,
      child: Column(
        children: [
          _buildActionButton(Icons.favorite_outline, '125K', isTablet),
          _buildActionButton(Icons.comment_outlined, '1.2K', isTablet),
          _buildActionButton(Icons.send_outlined, '', isTablet),
          _buildActionButton(Icons.more_vert, '', isTablet),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String count, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 28 : 20),
      child: Column(
        children: [
          Container(
            width: isTablet ? 64 : 48,
            height: isTablet ? 64 : 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: isTablet ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isTablet ? 28 : 24,
            ),
          ),
          if (count.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: isTablet ? 8 : 4),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 8 : 6,
                  vertical: isTablet ? 4 : 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(int index, bool isTablet) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: isTablet ? 120 : 80,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: isTablet ? 20 : 16,
                    backgroundImage: NetworkImage('https://picsum.photos/100/100?random=$index'),
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Text(
                  'user$index',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16 : 12,
                    vertical: isTablet ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: isTablet ? 8 : 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Follow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: isTablet ? 8 : 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              ),
              child: Text(
                'Amazing reel content here! #reels #viral #trending',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 16 : 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}