import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/post_models.dart';
// import '../widgets/filter_grid.dart';
// import '../widgets/adjustment_controls.dart';
// import '../widgets/crop_editor.dart';

class PostEditorPage extends StatefulWidget {
  final List<XFile> mediaFiles;
  final bool isCarousel;
  final Function(List<PostMedia>) onEditComplete;

  const PostEditorPage({
    Key? key,
    required this.mediaFiles,
    required this.isCarousel,
    required this.onEditComplete,
  }) : super(key: key);

  @override
  State<PostEditorPage> createState() => _PostEditorPageState();
}

class _PostEditorPageState extends State<PostEditorPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  
  int _currentMediaIndex = 0;
  List<PostMedia> _editedMedia = [];
  PostFilter? _selectedFilter;
  MediaAdjustments _adjustments = const MediaAdjustments();
  bool _showFilters = false;
  bool _showAdjustments = false;
  bool _showCrop = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    _initializeMedia();
  }

  void _initializeMedia() {
    _editedMedia = widget.mediaFiles.map((file) => PostMedia(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: file.path,
      type: file.path.endsWith('.mp4') ? MediaType.video : MediaType.photo,
      width: 1080,
      height: 1080,
      adjustments: const MediaAdjustments(),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Edit'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        actions: [
          TextButton(
            onPressed: _saveEdits,
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Media Preview
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentMediaIndex = index);
                  },
                  itemCount: _editedMedia.length,
                  itemBuilder: (context, index) {
                    return _buildMediaPreview(_editedMedia[index]);
                  },
                ),
                
                // Media Indicators
                if (widget.isCarousel)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_editedMedia.length, (index) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == _currentMediaIndex 
                                ? Colors.white 
                                : Colors.white54,
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),

          // Editor Controls
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[900],
              child: Column(
                children: [
                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.white,
                    tabs: const [
                      Tab(text: 'Filter'),
                      Tab(text: 'Adjust'),
                      Tab(text: 'Crop'),
                    ],
                  ),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Filters Tab
                        Center(child: Text('Filter Grid - Coming Soon')),
                        // FilterGrid(
                        //   selectedFilter: _selectedFilter,
                        //   onFilterSelected: (filter) {
                        //     setState(() => _selectedFilter = filter);
                        //     _applyFilter(filter);
                        //   },
                        // ),

                        // Adjustments Tab
                        Center(child: Text('Adjustment Controls - Coming Soon')),
                        // AdjustmentControls(
                        //   adjustments: _adjustments,
                        //   onAdjustmentChanged: (adjustments) {
                        //     setState(() => _adjustments = adjustments);
                        //     _applyAdjustments(adjustments);
                        //   },
                        // ),

                        // Crop Tab
                        Center(child: Text('Crop Editor - Coming Soon')),
                        // CropEditor(
                        //   mediaFile: widget.mediaFiles[_currentMediaIndex],
                        //   onCropChanged: (cropData) {
                        //     _applyCrop(cropData);
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(PostMedia media) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: media.type == MediaType.video
          ? Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(Icons.play_circle_filled, 
                               color: Colors.white, size: 64),
                  ),
                ),
                // Video preview would go here
              ],
            )
          : Image.file(
              File(media.url),
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
    );
  }

  void _applyFilter(PostFilter filter) {
    final currentMedia = _editedMedia[_currentMediaIndex];
    _editedMedia[_currentMediaIndex] = PostMedia(
      id: currentMedia.id,
      url: currentMedia.url,
      type: currentMedia.type,
      width: currentMedia.width,
      height: currentMedia.height,
      filter: filter,
      adjustments: currentMedia.adjustments,
      cropData: currentMedia.cropData,
    );
  }

  void _applyAdjustments(MediaAdjustments adjustments) {
    final currentMedia = _editedMedia[_currentMediaIndex];
    _editedMedia[_currentMediaIndex] = PostMedia(
      id: currentMedia.id,
      url: currentMedia.url,
      type: currentMedia.type,
      width: currentMedia.width,
      height: currentMedia.height,
      filter: currentMedia.filter,
      adjustments: adjustments,
      cropData: currentMedia.cropData,
    );
  }

  void _applyCrop(dynamic cropData) {
    final currentMedia = _editedMedia[_currentMediaIndex];
    _editedMedia[_currentMediaIndex] = PostMedia(
      id: currentMedia.id,
      url: currentMedia.url,
      type: currentMedia.type,
      width: currentMedia.width,
      height: currentMedia.height,
      filter: currentMedia.filter,
      adjustments: currentMedia.adjustments,
      cropData: cropData,
    );
  }

  void _saveEdits() {
    widget.onEditComplete(_editedMedia);
  }
}