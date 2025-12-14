import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedMedia = [];
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New post',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _selectedMedia.isNotEmpty ? _sharePost : null,
            child: Text(
              'Share',
              style: TextStyle(
                color: _selectedMedia.isNotEmpty ? const Color(0xFF0095F6) : const Color(0xFF8E8E8E),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFDBDBDB),
                  width: 0.5,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.black,
              indicatorWeight: 1,
              labelColor: Colors.black,
              unselectedLabelColor: const Color(0xFF8E8E8E),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Library'),
                Tab(text: 'Photo'),
                Tab(text: 'Video'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLibraryTab(),
                _buildCameraTab(false),
                _buildCameraTab(true),
              ],
            ),
          ),
          if (_selectedMedia.isNotEmpty) _buildPostComposer(),
        ],
      ),
    );
  }

  Widget _buildLibraryTab() {
    return Column(
      children: [
        if (_selectedMedia.isNotEmpty) _buildSelectedMediaPreview(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: 50, // Mock gallery items
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _selectFromGallery(),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Image.network(
                      'https://picsum.photos/400/400?random=$index',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image,
                        size: 40,
                        color: Color(0xFF8E8E8E),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCameraTab(bool isVideo) {
    return CameraPreviewWidget(
      isVideo: isVideo,
      onMediaCaptured: (XFile file) {
        setState(() {
          _selectedMedia = [file];
        });
      },
    );
  }

  Widget _buildSelectedMediaPreview() {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFDBDBDB),
            width: 0.5,
          ),
        ),
      ),
      child: Stack(
        children: [
          PageView.builder(
            itemCount: _selectedMedia.length,
            itemBuilder: (context, index) {
              final file = _selectedMedia[index];
              if (file.path.endsWith('.mp4')) {
                return VideoPreviewWidget(file: file);
              } else {
                return Image.file(
                  File(file.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              }
            },
          ),
          if (_selectedMedia.length > 1)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '1/${_selectedMedia.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostComposer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFDBDBDB),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://picsum.photos/100/100?random=user'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _captionController,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Write a caption...',
                    hintStyle: TextStyle(
                      color: Color(0xFF8E8E8E),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildComposerOption(
            icon: Icons.location_on_outlined,
            text: 'Add location',
            onTap: () => _showLocationPicker(),
          ),
          _buildComposerOption(
            icon: Icons.person_add_outlined,
            text: 'Tag people',
            onTap: _tagPeople,
          ),
          _buildComposerOption(
            icon: Icons.music_note_outlined,
            text: 'Add music',
            onTap: _addMusic,
          ),
        ],
      ),
    );
  }

  Widget _buildComposerOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.black,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF8E8E8E),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFDBDBDB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Add Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Search for a location...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF8E8E8E)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFDBDBDB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0095F6)),
                ),
              ),
            ),
            const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }



  void _selectFromGallery() async {
    final List<XFile> files = await _picker.pickMultipleMedia();
    if (files.isNotEmpty) {
      setState(() {
        _selectedMedia = files;
      });
    }
  }

  void _tagPeople() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tag People',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search people...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // List of suggested people
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
                    ),
                    title: Text('User $index'),
                    subtitle: const Text('@username'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addMusic() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Add Music',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search music...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.music_note),
                    ),
                    title: Text('Song Title $index'),
                    subtitle: const Text('Artist Name'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => Navigator.pop(context),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterPage(
          mediaFiles: _selectedMedia,
          onFiltersApplied: (filteredFiles) {
            setState(() {
              _selectedMedia = filteredFiles;
            });
          },
        ),
      ),
    );
  }

  void _editMedia() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaEditorPage(
          mediaFiles: _selectedMedia,
          onEditComplete: (editedFiles) {
            setState(() {
              _selectedMedia = editedFiles;
            });
          },
        ),
      ),
    );
  }

  void _sharePost() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Upload media files
      final mediaUrls = await _uploadMedia(_selectedMedia);
      
      // Create post
      await _createPost(
        caption: _captionController.text,
        location: _locationController.text,
        mediaUrls: mediaUrls,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post shared successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing post: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<String>> _uploadMedia(List<XFile> files) async {
    // Implement media upload to cloud storage
    await Future.delayed(const Duration(seconds: 2)); // Mock upload
    return files.map((file) => 'https://example.com/media/${file.name}').toList();
  }

  Future<void> _createPost({
    required String caption,
    required String location,
    required List<String> mediaUrls,
  }) async {
    // Implement post creation API call
    await Future.delayed(const Duration(seconds: 1)); // Mock API call
  }
}

class CameraPreviewWidget extends StatefulWidget {
  final bool isVideo;
  final Function(XFile) onMediaCaptured;

  const CameraPreviewWidget({
    super.key,
    required this.isVideo,
    required this.onMediaCaptured,
  });

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  CameraController? _cameraController;
  bool _isRecording = false;
  bool _isFlashOn = false;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras[_selectedCameraIndex],
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(_cameraController!),
        _buildCameraControls(),
      ],
    );
  }

  Widget _buildCameraControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black54],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Flash toggle
            IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _toggleFlash,
            ),
            
            // Capture button
            GestureDetector(
              onTap: widget.isVideo ? null : _takePicture,
              onLongPressStart: widget.isVideo ? (_) => _startRecording() : null,
              onLongPressEnd: widget.isVideo ? (_) => _stopRecording() : null,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: _isRecording ? Colors.red : Colors.transparent,
                ),
                child: _isRecording
                    ? const Icon(Icons.stop, color: Colors.white, size: 30)
                    : Icon(
                        widget.isVideo ? Icons.videocam : Icons.camera_alt,
                        color: Colors.white,
                        size: 30,
                      ),
              ),
            ),
            
            // Switch camera
            IconButton(
              icon: const Icon(
                Icons.flip_camera_ios,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _switchCamera,
            ),
          ],
        ),
      ),
    );
  }

  void _takePicture() async {
    try {
      final XFile photo = await _cameraController!.takePicture();
      widget.onMediaCaptured(photo);
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  void _startRecording() async {
    if (!_isRecording) {
      try {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        print('Error starting recording: $e');
      }
    }
  }

  void _stopRecording() async {
    if (_isRecording) {
      try {
        final XFile video = await _cameraController!.stopVideoRecording();
        setState(() {
          _isRecording = false;
        });
        widget.onMediaCaptured(video);
      } catch (e) {
        print('Error stopping recording: $e');
      }
    }
  }

  void _toggleFlash() async {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    await _cameraController!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  void _switchCamera() async {
    final cameras = await availableCameras();
    if (cameras.length > 1) {
      setState(() {
        _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras.length;
      });
      await _cameraController!.dispose();
      _initializeCamera();
    }
  }
}

class VideoPreviewWidget extends StatefulWidget {
  final XFile file;

  const VideoPreviewWidget({super.key, required this.file});

  @override
  State<VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.file.path))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );
  }
}

class FilterPage extends StatelessWidget {
  final List<XFile> mediaFiles;
  final Function(List<XFile>) onFiltersApplied;

  const FilterPage({
    super.key,
    required this.mediaFiles,
    required this.onFiltersApplied,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        actions: [
          TextButton(
            onPressed: () {
              onFiltersApplied(mediaFiles);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Filter Preview',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('Filter ${index + 1}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MediaEditorPage extends StatelessWidget {
  final List<XFile> mediaFiles;
  final Function(List<XFile>) onEditComplete;

  const MediaEditorPage({
    super.key,
    required this.mediaFiles,
    required this.onEditComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
        actions: [
          TextButton(
            onPressed: () {
              onEditComplete(mediaFiles);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Media Editor',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEditButton(Icons.crop, 'Crop'),
                _buildEditButton(Icons.tune, 'Adjust'),
                _buildEditButton(Icons.text_fields, 'Text'),
                _buildEditButton(Icons.brush, 'Draw'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(IconData icon, String label) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30),
          onPressed: () {},
        ),
        Text(label),
      ],
    );
  }
}