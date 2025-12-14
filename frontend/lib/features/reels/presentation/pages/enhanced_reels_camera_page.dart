import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/reels_bloc.dart';
import '../../data/models/reel_model.dart';

class EnhancedReelsCameraPage extends StatefulWidget {
  const EnhancedReelsCameraPage({super.key});

  @override
  State<EnhancedReelsCameraPage> createState() => _EnhancedReelsCameraPageState();
}

class _EnhancedReelsCameraPageState extends State<EnhancedReelsCameraPage>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  VideoPlayerController? _videoController;
  late AnimationController _recordingAnimationController;
  late AnimationController _timerAnimationController;
  late AnimationController _pulseAnimationController;
  
  bool _isRecording = false;
  bool _isBackCamera = true;
  bool _useTimer = false;
  int _timerDuration = 3;
  double _currentSpeed = 1.0;
  int _maxDuration = 30;
  int _recordedDuration = 0;
  
  List<CameraDescription> _cameras = [];
  List<String> _recordedSegments = [];
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _timerAnimationController = AnimationController(
      duration: Duration(seconds: _timerDuration),
      vsync: this,
    );
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _cameraController = CameraController(
        _cameras[_isBackCamera ? 0 : 1],
        ResolutionPreset.high,
        enableAudio: true,
      );
      await _cameraController!.initialize();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoController?.dispose();
    _recordingAnimationController.dispose();
    _timerAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<ReelsBloc, ReelsState>(
        listener: (context, state) {
          if (state is ReelRecorded) {
            _showPreview(state.videoPath);
          }
        },
        child: Stack(
          children: [
            _buildCameraPreview(),
            _buildTopControls(),
            _buildSideControls(),
            _buildBottomControls(),
            if (_useTimer) _buildTimerOverlay(),
            _buildRecordingIndicator(),
            _buildSpeedIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: CameraPreview(_cameraController!),
      ),
    );
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Row(
              children: [
                _buildSpeedControl(),
                const SizedBox(width: 12),
                _buildTimerControl(),
                const SizedBox(width: 12),
                _buildFlashControl(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedControl() {
    return PopupMenuButton<double>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Text(
          '${_currentSpeed}x',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      onSelected: (speed) {
        setState(() {
          _currentSpeed = speed;
        });
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 0.3, child: Text('0.3x')),
        const PopupMenuItem(value: 0.5, child: Text('0.5x')),
        const PopupMenuItem(value: 1.0, child: Text('1x')),
        const PopupMenuItem(value: 1.5, child: Text('1.5x')),
        const PopupMenuItem(value: 2.0, child: Text('2x')),
        const PopupMenuItem(value: 3.0, child: Text('3x')),
      ],
    );
  }

  Widget _buildTimerControl() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _useTimer = !_useTimer;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _useTimer ? Colors.white : Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(
            color: _useTimer ? AppColors.primary : Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.timer_rounded,
          color: _useTimer ? AppColors.primary : Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFlashControl() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: IconButton(
        icon: const Icon(Icons.flash_auto_rounded, color: Colors.white, size: 20),
        onPressed: () {
          // Toggle flash mode
        },
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildSideControls() {
    return Positioned(
      right: 20,
      top: MediaQuery.of(context).size.height * 0.25,
      child: Column(
        children: [
          _buildSideButton(
            icon: Icons.music_note_rounded,
            label: 'Audio',
            onTap: () => _showAudioSelector(),
          ),
          const SizedBox(height: 24),
          _buildSideButton(
            icon: Icons.auto_fix_high_rounded,
            label: 'Effects',
            onTap: () => _showEffectsSelector(),
          ),
          const SizedBox(height: 24),
          _buildSideButton(
            icon: Icons.face_retouching_natural_rounded,
            label: 'Beauty',
            onTap: () => _showBeautyFilters(),
          ),
          const SizedBox(height: 24),
          _buildSideButton(
            icon: Icons.view_in_ar_rounded,
            label: 'AR',
            onTap: () => _showAREffects(),
          ),
          const SizedBox(height: 24),
          _buildSideButton(
            icon: Icons.dashboard_customize_rounded,
            label: 'Template',
            onTap: () => _showTemplates(),
          ),
        ],
      ),
    );
  }

  Widget _buildSideButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
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
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGalleryButton(),
              _buildRecordButton(),
              _buildFlipCameraButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: () => _selectFromGallery(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      onTap: _useTimer ? _startTimerRecording : null,
      child: AnimatedBuilder(
        animation: _recordingAnimationController,
        builder: (context, child) {
          return Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isRecording ? Colors.red.withOpacity(0.5) : Colors.black.withOpacity(0.3),
                  blurRadius: _isRecording ? 20 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isRecording ? 36 : 68,
                height: _isRecording ? 36 : 68,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red : Colors.red,
                  borderRadius: BorderRadius.circular(_isRecording ? 8 : 34),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFlipCameraButton() {
    return GestureDetector(
      onTap: _flipCamera,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildTimerOverlay() {
    return AnimatedBuilder(
      animation: _timerAnimationController,
      builder: (context, child) {
        final remaining = (_timerDuration * (1 - _timerAnimationController.value)).ceil();
        return Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                '$remaining',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecordingIndicator() {
    if (!_isRecording) return const SizedBox.shrink();

    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimationController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(_pulseAnimationController.value * 0.5),
                      blurRadius: 20,
                      spreadRadius: _pulseAnimationController.value * 5,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'REC ${_recordedDuration}s / ${_maxDuration}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _recordedDuration / _maxDuration,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red, Colors.red.shade300],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedIndicator() {
    if (_currentSpeed == 1.0) return const SizedBox.shrink();

    return Positioned(
      top: 200,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          '${_currentSpeed}x Speed',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _startRecording() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    HapticFeedback.heavyImpact();
    setState(() {
      _isRecording = true;
    });

    _recordingAnimationController.forward();
    context.read<ReelsBloc>().add(RecordReel(
      duration: _maxDuration,
      speed: _currentSpeed,
    ));
  }

  void _stopRecording() {
    if (!_isRecording) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isRecording = false;
    });

    _recordingAnimationController.reverse();
  }

  void _startTimerRecording() {
    _timerAnimationController.forward().then((_) {
      _startRecording();
      Future.delayed(Duration(seconds: _maxDuration), () {
        _stopRecording();
      });
    });
  }

  void _flipCamera() async {
    if (_cameras.length < 2) return;

    HapticFeedback.selectionClick();
    setState(() {
      _isBackCamera = !_isBackCamera;
    });

    await _cameraController?.dispose();
    _cameraController = CameraController(
      _cameras[_isBackCamera ? 0 : 1],
      ResolutionPreset.high,
      enableAudio: true,
    );
    await _cameraController!.initialize();
    setState(() {});
  }

  void _selectFromGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReelsGalleryPage(),
      ),
    );
  }

  void _showAudioSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AudioSelectorSheet(),
    );
  }

  void _showEffectsSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EffectsSelectorSheet(),
    );
  }

  void _showBeautyFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BeautyFiltersSheet(),
    );
  }

  void _showAREffects() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AREffectsSheet(),
    );
  }

  void _showTemplates() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TemplatesSheet(),
    );
  }

  void _showPreview(String videoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReelsPreviewPage(videoPath: videoPath),
      ),
    );
  }
}

// Enhanced bottom sheets with modern design
class AudioSelectorSheet extends StatelessWidget {
  const AudioSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.music_note_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Audio',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildAudioOption(Icons.trending_up_rounded, 'Trending', 'Popular tracks'),
                  _buildAudioOption(Icons.library_music_rounded, 'Music Library', 'Browse all music'),
                  _buildAudioOption(Icons.mic_rounded, 'Original Audio', 'Use device microphone'),
                  _buildAudioOption(Icons.upload_rounded, 'Upload Audio', 'Add your own track'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioOption(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.secondaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () {},
      ),
    );
  }
}

class EffectsSelectorSheet extends StatelessWidget {
  const EffectsSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(child: Text('Effects Selector')),
      ),
    );
  }
}

class BeautyFiltersSheet extends StatelessWidget {
  const BeautyFiltersSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(child: Text('Beauty Filters')),
      ),
    );
  }
}

class AREffectsSheet extends StatelessWidget {
  const AREffectsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(child: Text('AR Effects')),
      ),
    );
  }
}

class TemplatesSheet extends StatelessWidget {
  const TemplatesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(child: Text('Templates')),
      ),
    );
  }
}

// Placeholder pages
class ReelsGalleryPage extends StatelessWidget {
  const ReelsGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Gallery'),
      ),
      body: const Center(child: Text('Gallery Selection')),
    );
  }
}

class ReelsPreviewPage extends StatelessWidget {
  final String videoPath;

  const ReelsPreviewPage({super.key, required this.videoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Preview'),
      ),
      body: Center(child: Text('Preview: $videoPath')),
    );
  }
}