import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../models/story_models.dart';
import '../widgets/camera_controls.dart';
import '../widgets/filter_selector.dart';
import '../widgets/ar_filter_overlay.dart';
import '../editor/story_editor_page.dart';

class StoryCameraPage extends StatefulWidget {
  const StoryCameraPage({super.key});

  @override
  State<StoryCameraPage> createState() => _StoryCameraPageState();
}

class _StoryCameraPageState extends State<StoryCameraPage>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isRecording = false;
  bool _isHandsFree = false;
  bool _isBoomerang = false;
  bool _isSuperzoom = false;
  bool _isLayoutMode = false;
  bool _isMultiCapture = false;
  CameraFilter? _selectedFilter;
  ARFilter? _selectedARFilter;
  
  late AnimationController _recordingAnimationController;
  late AnimationController _zoomAnimationController;
  
  double _currentZoom = 1.0;
  double _maxZoom = 1.0;
  int _selectedCameraIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _zoomAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras[_selectedCameraIndex],
          ResolutionPreset.high,
          enableAudio: true,
        );
        await _cameraController!.initialize();
        _maxZoom = await _cameraController!.getMaxZoomLevel();
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _recordingAnimationController.dispose();
    _zoomAnimationController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      final image = await _cameraController!.takePicture();
      
      if (_isBoomerang) {
        await _captureBoomerang();
      } else if (_isMultiCapture) {
        await _captureMultiple();
      } else {
        _navigateToEditor(image.path, MediaType.photo);
      }
    } catch (e) {
      _showError('Failed to capture photo: $e');
    }
  }

  Future<void> _startVideoRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      await _cameraController!.startVideoRecording();
      setState(() => _isRecording = true);
      _recordingAnimationController.repeat();
      
      if (_isSuperzoom) {
        _performSuperzoom();
      }
      
      if (_isHandsFree) {
        _startHandsFreeRecording();
      }
    } catch (e) {
      _showError('Failed to start recording: $e');
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_cameraController == null || !_isRecording) return;

    try {
      final video = await _cameraController!.stopVideoRecording();
      setState(() => _isRecording = false);
      _recordingAnimationController.stop();
      
      _navigateToEditor(video.path, MediaType.video);
    } catch (e) {
      _showError('Failed to stop recording: $e');
    }
  }

  Future<void> _captureBoomerang() async {
    // Capture multiple frames for boomerang effect
    List<String> frames = [];
    for (int i = 0; i < 10; i++) {
      final image = await _cameraController!.takePicture();
      frames.add(image.path);
      await Future.delayed(const Duration(milliseconds: 100));
    }
    // Process frames into boomerang video
    _navigateToEditor(frames.first, MediaType.boomerang);
  }

  Future<void> _captureMultiple() async {
    // Capture multiple photos in sequence
    List<String> photos = [];
    for (int i = 0; i < 4; i++) {
      final image = await _cameraController!.takePicture();
      photos.add(image.path);
      await Future.delayed(const Duration(milliseconds: 500));
    }
    _navigateToEditor(photos.first, MediaType.multiCapture);
  }

  void _performSuperzoom() {
    _zoomAnimationController.forward().then((_) {
      _cameraController!.setZoomLevel(_maxZoom * 0.8);
    });
  }

  void _startHandsFreeRecording() {
    Future.delayed(const Duration(seconds: 15), () {
      if (_isRecording) _stopVideoRecording();
    });
  }

  void _switchCamera() {
    if (_cameras.length > 1) {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
      _initializeCamera();
    }
  }

  void _navigateToEditor(String mediaPath, MediaType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryEditorPage(
          mediaPath: mediaPath,
          mediaType: type,
          selectedFilter: _selectedFilter,
          selectedARFilter: _selectedARFilter,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Initializing Camera...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return Stack(
            children: [
          // Camera Preview
          Positioned.fill(
            child: GestureDetector(
              onScaleUpdate: (details) {
                final zoom = (_currentZoom * details.scale).clamp(1.0, _maxZoom);
                _cameraController!.setZoomLevel(zoom);
              },
              onScaleEnd: (details) {
                _currentZoom = _cameraController!.value.zoomLevel;
              },
              child: CameraPreview(_cameraController!),
            ),
          ),

          // AR Filter Overlay
          if (_selectedARFilter != null)
            Positioned.fill(
              child: ARFilterOverlay(filter: _selectedARFilter!),
            ),

              // Top Controls
              Positioned(
                top: MediaQuery.of(context).padding.top + (isTablet ? 24 : 16),
                left: isTablet ? 24 : 16,
                right: isTablet ? 24 : 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: isTablet ? 32 : 28,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: isTablet ? 12 : 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                          ),
                          child: IconButton(
                            onPressed: () => setState(() => _isHandsFree = !_isHandsFree),
                            icon: Icon(
                              Icons.timer,
                              color: _isHandsFree ? AppColors.warning : Colors.white,
                              size: isTablet ? 28 : 24,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: isTablet ? 12 : 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.flash_off,
                              color: Colors.white,
                              size: isTablet ? 28 : 24,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                          ),
                          child: IconButton(
                            onPressed: _switchCamera,
                            icon: Icon(
                              Icons.flip_camera_ios,
                              color: Colors.white,
                              size: isTablet ? 28 : 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Camera Mode Selector
              Positioned(
                left: isTablet ? 24 : 16,
                top: MediaQuery.of(context).size.height * 0.3,
                child: Column(
                  children: [
                    _buildModeButton('NORMAL', !_isBoomerang && !_isSuperzoom && !_isLayoutMode, isTablet),
                    SizedBox(height: isTablet ? 20 : 16),
                    _buildModeButton('BOOMERANG', _isBoomerang, isTablet),
                    SizedBox(height: isTablet ? 20 : 16),
                    _buildModeButton('SUPERZOOM', _isSuperzoom, isTablet),
                    SizedBox(height: isTablet ? 20 : 16),
                    _buildModeButton('LAYOUT', _isLayoutMode, isTablet),
                    SizedBox(height: isTablet ? 20 : 16),
                    _buildModeButton('MULTI', _isMultiCapture, isTablet),
                  ],
                ),
              ),

              // Filter Selector
              Positioned(
                bottom: isTablet ? 240 : 200,
                left: 0,
                right: 0,
                child: FilterSelector(
                  onFilterSelected: (filter) {
                    setState(() => _selectedFilter = filter);
                  },
                  onARFilterSelected: (arFilter) {
                    setState(() => _selectedARFilter = arFilter);
                  },
                ),
              ),

              // Camera Controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CameraControls(
                  isRecording: _isRecording,
                  onCapturePhoto: _capturePhoto,
                  onStartRecording: _startVideoRecording,
                  onStopRecording: _stopVideoRecording,
                  recordingAnimation: _recordingAnimationController,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModeButton(String label, bool isSelected, bool isTablet) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isBoomerang = label == 'BOOMERANG';
          _isSuperzoom = label == 'SUPERZOOM';
          _isLayoutMode = label == 'LAYOUT';
          _isMultiCapture = label == 'MULTI';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 12 : 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: isTablet ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}