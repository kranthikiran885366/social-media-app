import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class VideoCallPage extends StatefulWidget {
  final String callId;
  final String participantName;
  final String participantAvatar;
  final bool isIncoming;

  const VideoCallPage({
    super.key,
    required this.callId,
    required this.participantName,
    required this.participantAvatar,
    this.isIncoming = false,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerOn = false;
  bool _isCallConnected = false;
  bool _showControls = true;
  Duration _callDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseAnimationController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeInOut),
    );

    if (!widget.isIncoming) {
      _pulseAnimationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  void _hideControls() {
    setState(() {
      _showControls = false;
    });
    _fadeAnimationController.forward();
  }

  void _showControls() {
    setState(() {
      _showControls = true;
    });
    _fadeAnimationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return GestureDetector(
            onTap: () {
              if (_isCallConnected) {
                if (_showControls) {
                  _hideControls();
                } else {
                  _showControls();
                }
              }
            },
            child: Stack(
              children: [
                _buildVideoBackground(isTablet),
                _buildTopBar(isTablet),
                _buildBottomControls(isTablet),
                if (widget.isIncoming && !_isCallConnected)
                  _buildIncomingCallOverlay(isTablet),
                if (_isCallConnected && _isVideoEnabled)
                  _buildSelfVideoPreview(isTablet),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoBackground(bool isTablet) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            AppColors.primary.withOpacity(0.2),
            Colors.black.withOpacity(0.9),
          ],
        ),
      ),
      child: _isCallConnected && _isVideoEnabled
          ? Container(
              color: Colors.grey[900],
              child: const Center(
                child: Icon(
                  Icons.videocam_rounded,
                  size: 100,
                  color: Colors.white30,
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: widget.isIncoming ? 1.0 : _pulseAnimation.value,
                        child: Container(
                          width: isTablet ? 280 : 220,
                          height: isTablet ? 280 : 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: isTablet ? 40 : 30,
                                spreadRadius: isTablet ? 15 : 10,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(isTablet ? 12 : 8),
                          child: CircleAvatar(
                            radius: isTablet ? 134 : 106,
                            backgroundImage: NetworkImage(widget.participantAvatar),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: isTablet ? 56 : 40),
                  Text(
                    widget.participantName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 36 : 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: isTablet ? 8 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getCallStatusText(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
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
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _showControls ? 1.0 : _fadeAnimation.value,
            child: Container(
              padding: EdgeInsets.all(isTablet ? 28 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: isTablet ? 28 : 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Spacer(),
                  if (_isCallConnected)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16,
                        vertical: isTablet ? 12 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _formatDuration(_callDuration),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                      onPressed: _showMoreOptions,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomControls(bool isTablet) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _showControls ? 1.0 : _fadeAnimation.value,
              child: Container(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                      isActive: _isSpeakerOn,
                      isTablet: isTablet,
                      onTap: () {
                        setState(() {
                          _isSpeakerOn = !_isSpeakerOn;
                        });
                      },
                    ),
                    _buildControlButton(
                      icon: _isVideoEnabled ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                      isActive: _isVideoEnabled,
                      isTablet: isTablet,
                      onTap: () {
                        setState(() {
                          _isVideoEnabled = !_isVideoEnabled;
                        });
                      },
                    ),
                    _buildControlButton(
                      icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      isActive: !_isMuted,
                      isTablet: isTablet,
                      onTap: () {
                        setState(() {
                          _isMuted = !_isMuted;
                        });
                      },
                    ),
                    _buildControlButton(
                      icon: Icons.call_end_rounded,
                      isActive: false,
                      isEndCall: true,
                      isTablet: isTablet,
                      onTap: _endCall,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required bool isTablet,
    bool isEndCall = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: isTablet ? 80 : 64,
        height: isTablet ? 80 : 64,
        decoration: BoxDecoration(
          gradient: isEndCall
              ? LinearGradient(colors: [Colors.red, Colors.red.withOpacity(0.8)])
              : isActive
                  ? AppColors.primaryGradient.scale(0.3)
                  : null,
          color: isEndCall || isActive ? null : Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(
            color: isEndCall
                ? Colors.red.withOpacity(0.8)
                : isActive
                    ? Colors.white.withOpacity(0.6)
                    : Colors.white.withOpacity(0.4),
            width: isTablet ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isEndCall
                  ? Colors.red.withOpacity(0.4)
                  : isActive
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.black.withOpacity(0.3),
              blurRadius: isTablet ? 15 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isTablet ? 36 : 28,
        ),
      ),
    );
  }

  Widget _buildIncomingCallOverlay(bool isTablet) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.9),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Spacer(),
          Text(
            'Incoming video call',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            widget.participantName,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 36 : 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.all(isTablet ? 56 : 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _declineCall,
                  child: Container(
                    width: isTablet ? 100 : 80,
                    height: isTablet ? 100 : 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red, Colors.red.withOpacity(0.8)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: isTablet ? 20 : 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.call_end_rounded,
                      color: Colors.white,
                      size: isTablet ? 44 : 36,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _acceptCall,
                  child: Container(
                    width: isTablet ? 100 : 80,
                    height: isTablet ? 100 : 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: isTablet ? 20 : 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.call_rounded,
                      color: Colors.white,
                      size: isTablet ? 44 : 36,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSelfVideoPreview(bool isTablet) {
    return Positioned(
      top: isTablet ? 140 : 100,
      right: isTablet ? 32 : 20,
      child: Container(
        width: isTablet ? 160 : 120,
        height: isTablet ? 200 : 160,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: isTablet ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: isTablet ? 15 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTablet ? 17 : 14),
          child: Container(
            color: Colors.grey[800],
            child: Center(
              child: Icon(
                Icons.person_rounded,
                color: Colors.white54,
                size: isTablet ? 56 : 40,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getCallStatusText() {
    if (widget.isIncoming && !_isCallConnected) {
      return 'Incoming call...';
    } else if (!_isCallConnected) {
      return 'Calling...';
    } else {
      return 'Connected';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _acceptCall() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isCallConnected = true;
    });
    _pulseAnimationController.stop();
  }

  void _declineCall() {
    HapticFeedback.heavyImpact();
    Navigator.pop(context);
  }

  void _endCall() {
    HapticFeedback.heavyImpact();
    Navigator.pop(context);
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat_rounded),
              title: const Text('Send Message'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.screen_share_rounded),
              title: const Text('Share Screen'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}