import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
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
      body: Stack(
        children: [
          _buildCameraPreview(),
          _buildSetupOverlay(),
        ],
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
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildSetupOverlay() {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(),
          const Spacer(),
          _buildSetupPanel(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: _switchCamera,
          ),
        ],
      ),
    );
  }

  Widget _buildSetupPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Go Live',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Add a title...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startLive,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Start Live Video',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildSettingTile(
          'Allow comments',
          _commentsEnabled,
          (value) => setState(() => _commentsEnabled = value),
        ),
        _buildSettingTile(
          'Allow guests',
          _guestsEnabled,
          (value) => setState(() => _guestsEnabled = value),
        ),
        _buildSettingTile(
          'Enable shopping',
          _shoppingEnabled,
          (value) => setState(() => _shoppingEnabled = value),
        ),
      ],
    );
  }

  Widget _buildSettingTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
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
        builder: (context) => const LiveStreamPage(isHost: true),
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