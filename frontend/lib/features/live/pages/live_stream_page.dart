import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LiveStreamPage extends StatefulWidget {
  const LiveStreamPage({super.key});

  @override
  State<LiveStreamPage> createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLive = false;
  int _viewerCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return Stack(
            children: [
              _buildVideoStream(isTablet),
              _buildTopBar(isTablet),
              _buildComments(isTablet),
              _buildBottomControls(isTablet),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVideoStream(bool isTablet) {
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
            Colors.black.withOpacity(0.9),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isTablet ? 160 : 120,
              height: isTablet ? 160 : 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient.scale(0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: isTablet ? 30 : 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                _isLive ? Icons.videocam : Icons.videocam_off,
                size: isTablet ? 80 : 60,
                color: Colors.white,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: isTablet ? 12 : 8,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _isLive ? 'LIVE' : 'Tap to go live',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 22 : 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isTablet) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: isTablet ? 28 : 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Spacer(),
            if (_isLive) ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: isTablet ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withOpacity(0.4),
                      blurRadius: isTablet ? 12 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: isTablet ? 10 : 8,
                      height: isTablet ? 10 : 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: isTablet ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility,
                      color: Colors.white,
                      size: isTablet ? 18 : 16,
                    ),
                    SizedBox(width: isTablet ? 6 : 4),
                    Text(
                      '$_viewerCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComments(bool isTablet) {
    if (!_isLive) return const SizedBox.shrink();
    
    return Positioned(
      left: isTablet ? 24 : 16,
      right: isTablet ? 24 : 16,
      bottom: isTablet ? 160 : 120,
      child: Container(
        height: isTablet ? 240 : 200,
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) => _buildCommentItem(index, isTablet),
        ),
      ),
    );
  }

  Widget _buildCommentItem(int index, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 16 : 14,
          ),
          children: [
            TextSpan(
              text: 'user$index ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary.withOpacity(0.8),
              ),
            ),
            const TextSpan(text: 'Great live stream! 🔥'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(bool isTablet) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLive) _buildMessageInput(isTablet),
            SizedBox(height: isTablet ? 24 : 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  Icons.flip_camera_ios,
                  'Flip',
                  () {},
                  isTablet,
                ),
                _buildLiveButton(isTablet),
                _buildControlButton(
                  Icons.mic_off,
                  'Mute',
                  () {},
                  isTablet,
                ),
                _buildControlButton(
                  Icons.more_horiz,
                  'More',
                  () {},
                  isTablet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isTablet) {
    return Container(
      height: isTablet ? 56 : 44,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(isTablet ? 28 : 22),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _messageController,
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 16 : 14,
        ),
        decoration: InputDecoration(
          hintText: 'Say something...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: isTablet ? 16 : 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 16 : 12,
          ),
          suffixIcon: Container(
            margin: EdgeInsets.all(isTablet ? 8 : 6),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            ),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.white,
                size: isTablet ? 20 : 18,
              ),
              onPressed: () {
                _messageController.clear();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveButton(bool isTablet) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isLive = !_isLive;
          if (_isLive) {
            _viewerCount = 1;
          } else {
            _viewerCount = 0;
          }
        });
      },
      child: Container(
        width: isTablet ? 100 : 80,
        height: isTablet ? 100 : 80,
        decoration: BoxDecoration(
          gradient: _isLive ? AppColors.secondaryGradient : AppColors.primaryGradient,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: isTablet ? 4 : 3,
          ),
          boxShadow: [
            BoxShadow(
              color: (_isLive ? AppColors.secondary : AppColors.primary).withOpacity(0.4),
              blurRadius: isTablet ? 20 : 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          _isLive ? Icons.stop : Icons.play_arrow,
          color: Colors.white,
          size: isTablet ? 40 : 32,
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onTap, bool isTablet) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isTablet ? 64 : 50,
            height: isTablet ? 64 : 50,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
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
          SizedBox(height: isTablet ? 8 : 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}