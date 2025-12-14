import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../core/theme/app_colors.dart';
import 'live_stream_page.dart';

class LiveSetupPage extends StatefulWidget {
  const LiveSetupPage({super.key});

  @override
  State<LiveSetupPage> createState() => _LiveSetupPageState();
}

class _LiveSetupPageState extends State<LiveSetupPage> {
  CameraController? _cameraController;
  final TextEditingController _titleController = TextEditingController();
  bool _commentsEnabled = true;
  bool _guestsEnabled = true;
  bool _shoppingEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return Stack(
            children: [
              _buildCameraPreview(),
              _buildSetupOverlay(isTablet),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraController?.value.isInitialized == true) {
      return SizedBox.expand(
        child: CameraPreview(_cameraController!),
      );
    }
    return Container(
      color: Colors.black,
      child: Center(
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

  Widget _buildSetupOverlay(bool isTablet) {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(isTablet),
          const Spacer(),
          _buildSetupPanel(isTablet),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.flip_camera_ios,
                color: Colors.white,
                size: isTablet ? 28 : 24,
              ),
              onPressed: _switchCamera,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupPanel(bool isTablet) {
    return Container(
      margin: EdgeInsets.all(isTablet ? 24 : 16),
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: isTablet ? 20 : 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                ),
                child: Icon(
                  Icons.live_tv,
                  color: Colors.white,
                  size: isTablet ? 32 : 24,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'Go Live',
                style: TextStyle(
                  fontSize: isTablet ? 32 : 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 24 : 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _titleController,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Add a title...',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: isTablet ? 18 : 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),
          _buildSettingsSection(isTablet),
          SizedBox(height: isTablet ? 32 : 24),
          Container(
            width: double.infinity,
            height: isTablet ? 64 : 56,
            decoration: BoxDecoration(
              gradient: AppColors.errorGradient,
              borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.4),
                  blurRadius: isTablet ? 20 : 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                onTap: _startLive,
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.live_tv,
                        color: Colors.white,
                        size: isTablet ? 28 : 24,
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Text(
                        'Start Live Video',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: isTablet ? 20 : 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          _buildSettingTile(
            'Allow comments',
            _commentsEnabled,
            (value) => setState(() => _commentsEnabled = value),
            isTablet,
          ),
          _buildSettingTile(
            'Allow guests',
            _guestsEnabled,
            (value) => setState(() => _guestsEnabled = value),
            isTablet,
          ),
          _buildSettingTile(
            'Enable shopping',
            _shoppingEnabled,
            (value) => setState(() => _shoppingEnabled = value),
            isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(String title, bool value, Function(bool) onChanged, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Transform.scale(
            scale: isTablet ? 1.2 : 1.0,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();
      setState(() {});
    }
  }

  void _switchCamera() async {
    if (_cameraController != null) {
      final cameras = await availableCameras();
      final currentCamera = _cameraController!.description;
      final newCamera = cameras.firstWhere(
        (camera) => camera != currentCamera,
        orElse: () => cameras.first,
      );
      
      await _cameraController!.dispose();
      _cameraController = CameraController(newCamera, ResolutionPreset.high);
      await _cameraController!.initialize();
      setState(() {});
    }
  }

  void _startLive() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LiveStreamPage(),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _titleController.dispose();
    super.dispose();
  }
}