import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import '../bloc/reels_bloc.dart';
import '../../data/models/reel_model.dart';

class ReelsCameraPage extends StatefulWidget {
  const ReelsCameraPage({super.key});

  @override
  State<ReelsCameraPage> createState() => _ReelsCameraPageState();
}

class _ReelsCameraPageState extends State<ReelsCameraPage>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  VideoPlayerController? _videoController;
  late AnimationController _recordingAnimationController;
  late AnimationController _timerAnimationController;
  
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
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox.expand(
      child: CameraPreview(_cameraController!),
    );
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
            Row(
              children: [
                _buildSpeedControl(),
                const SizedBox(width: 16),
                _buildTimerControl(),
                const SizedBox(width: 16),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${_currentSpeed}x',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _useTimer ? Colors.white : Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.timer,
          color: _useTimer ? Colors.black : Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildFlashControl() {
    return IconButton(
      icon: const Icon(Icons.flash_auto, color: Colors.white, size: 24),
      onPressed: () {
        // Toggle flash mode
      },
    );
  }

  Widget _buildSideControls() {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).size.height * 0.3,
      child: Column(
        children: [
          _buildSideButton(
            icon: Icons.music_note,
            label: 'Audio',
            onTap: () => _showAudioSelector(),
          ),
          const SizedBox(height: 20),
          _buildSideButton(
            icon: Icons.auto_fix_high,
            label: 'Effects',
            onTap: () => _showEffectsSelector(),
          ),
          const SizedBox(height: 20),
          _buildSideButton(
            icon: Icons.face_retouching_natural,
            label: 'Beauty',
            onTap: () => _showBeautyFilters(),
          ),
          const SizedBox(height: 20),
          _buildSideButton(
            icon: Icons.view_in_ar,
            label: 'AR',
            onTap: () => _showAREffects(),
          ),
          const SizedBox(height: 20),
          _buildSideButton(
            icon: Icons.dashboard_customize,
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
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.photo_library, color: Colors.white),
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
            ),
            child: Center(
              child: Container(
                width: _isRecording ? 30 : 60,
                height: _isRecording ? 30 : 60,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(_isRecording ? 8 : 30),
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
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.flip_camera_ios, color: Colors.white),
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
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$remaining',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
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
      top: 100,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_recordedDuration}s / ${_maxDuration}s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _recordedDuration / _maxDuration,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startRecording() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

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
    // Implement gallery selection
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

// Placeholder widgets for the bottom sheets
class AudioSelectorSheet extends StatelessWidget {
  const AudioSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Add Audio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  ListTile(
                    leading: const Icon(Icons.trending_up),
                    title: const Text('Trending'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.library_music),
                    title: const Text('Music Library'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.mic),
                    title: const Text('Original Audio'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
      appBar: AppBar(title: const Text('Gallery')),
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
      appBar: AppBar(title: const Text('Preview')),
      body: Center(child: Text('Preview: $videoPath')),
    );
  }
}