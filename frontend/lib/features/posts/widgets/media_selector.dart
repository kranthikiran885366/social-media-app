import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class MediaSelector extends StatefulWidget {
  final Function(List<XFile>) onMediaSelected;
  final int maxSelection;
  final bool allowVideo;
  final int maxVideoDuration;

  const MediaSelector({
    Key? key,
    required this.onMediaSelected,
    this.maxSelection = 10,
    this.allowVideo = true,
    this.maxVideoDuration = 60,
  }) : super(key: key);

  @override
  State<MediaSelector> createState() => _MediaSelectorState();
}

class _MediaSelectorState extends State<MediaSelector> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedMedia = [];
  List<XFile> _galleryMedia = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGalleryMedia();
  }

  Future<void> _loadGalleryMedia() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      // In a real app, you'd use a plugin like photo_manager to load gallery media
      // For now, we'll simulate with empty list
      setState(() {
        _galleryMedia = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Camera and Gallery Options
        Container(
          height: 100,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Camera Button
              Expanded(
                child: GestureDetector(
                  onTap: _openCamera,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 32),
                        SizedBox(height: 4),
                        Text('Camera'),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Gallery Button
              Expanded(
                child: GestureDetector(
                  onTap: _openGallery,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library, size: 32),
                        SizedBox(height: 4),
                        Text('Gallery'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Selected Media Preview
        if (_selectedMedia.isNotEmpty) ...[
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedMedia.length,
              itemBuilder: (context, index) {
                final media = _selectedMedia[index];
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: media.path.endsWith('.mp4')
                            ? Container(
                                color: Colors.black,
                                child: const Center(
                                  child: Icon(Icons.play_circle_filled, 
                                             color: Colors.white, size: 32),
                                ),
                              )
                            : Image.file(File(media.path), fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeMedia(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onMediaSelected(_selectedMedia),
                child: Text('Continue with ${_selectedMedia.length} item${_selectedMedia.length > 1 ? 's' : ''}'),
              ),
            ),
          ),
        ],

        // Gallery Grid
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _galleryMedia.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No photos found', style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 8),
                          Text('Take a photo or select from gallery', 
                               style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: _galleryMedia.length,
                      itemBuilder: (context, index) {
                        final media = _galleryMedia[index];
                        final isSelected = _selectedMedia.contains(media);
                        
                        return GestureDetector(
                          onTap: () => _toggleMediaSelection(media),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(media.path), fit: BoxFit.cover),
                              ),
                              if (isSelected)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${_selectedMedia.indexOf(media) + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Future<void> _openCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedMedia = [photo];
      });
      widget.onMediaSelected(_selectedMedia);
    }
  }

  Future<void> _openGallery() async {
    final List<XFile> media = await _picker.pickMultipleMedia(
      limit: widget.maxSelection,
    );
    
    if (media.isNotEmpty) {
      setState(() {
        _selectedMedia = media;
      });
      widget.onMediaSelected(_selectedMedia);
    }
  }

  void _toggleMediaSelection(XFile media) {
    setState(() {
      if (_selectedMedia.contains(media)) {
        _selectedMedia.remove(media);
      } else if (_selectedMedia.length < widget.maxSelection) {
        _selectedMedia.add(media);
      }
    });
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }
}

class FilterGrid extends StatelessWidget {
  final dynamic selectedFilter;
  final Function(dynamic) onFilterSelected;

  const FilterGrid({
    Key? key,
    this.selectedFilter,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'name': 'Normal', 'id': 'normal'},
      {'name': 'Clarendon', 'id': 'clarendon'},
      {'name': 'Gingham', 'id': 'gingham'},
      {'name': 'Moon', 'id': 'moon'},
      {'name': 'Lark', 'id': 'lark'},
      {'name': 'Reyes', 'id': 'reyes'},
      {'name': 'Juno', 'id': 'juno'},
      {'name': 'Slumber', 'id': 'slumber'},
    ];

    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter?.id == filter['id'];
          
          return GestureDetector(
            onTap: () => onFilterSelected(filter),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected 
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: const Icon(Icons.filter, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    filter['name']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontSize: 12,
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
}

class AdjustmentControls extends StatelessWidget {
  final dynamic adjustments;
  final Function(dynamic) onAdjustmentChanged;

  const AdjustmentControls({
    Key? key,
    required this.adjustments,
    required this.onAdjustmentChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSlider('Brightness', 0.0, (value) {}),
          _buildSlider('Contrast', 0.0, (value) {}),
          _buildSlider('Saturation', 0.0, (value) {}),
          _buildSlider('Warmth', 0.0, (value) {}),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white)),
            Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.white)),
          ],
        ),
        Slider(
          value: value,
          min: -1.0,
          max: 1.0,
          onChanged: onChanged,
          activeColor: Colors.white,
          inactiveColor: Colors.grey,
        ),
      ],
    );
  }
}

class CropEditor extends StatelessWidget {
  final XFile mediaFile;
  final Function(dynamic) onCropChanged;

  const CropEditor({
    Key? key,
    required this.mediaFile,
    required this.onCropChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Crop & Rotate', style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 16),
          
          // Aspect Ratio Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAspectRatioButton('Original', () {}),
              _buildAspectRatioButton('1:1', () {}),
              _buildAspectRatioButton('4:5', () {}),
              _buildAspectRatioButton('16:9', () {}),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Rotate Button
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.rotate_right),
            label: const Text('Rotate'),
          ),
        ],
      ),
    );
  }

  Widget _buildAspectRatioButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}