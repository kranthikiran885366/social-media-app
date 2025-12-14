import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../models/post_models.dart;
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return Column(
            children: [
              // Top Bar
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            size: isTablet ? 32 : 28,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 16,
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
                          'Edit Media',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: isTablet ? 12 : 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                            onTap: _saveEdits,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 20 : 16,
                                vertical: isTablet ? 12 : 8,
                              ),
                              child: Text(
                                'Done',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Media Preview
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
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
                            top: isTablet ? 24 : 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_editedMedia.length, (index) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: index == _currentMediaIndex ? (isTablet ? 24 : 20) : (isTablet ? 12 : 8),
                                  height: isTablet ? 12 : 8,
                                  margin: EdgeInsets.symmetric(horizontal: isTablet ? 4 : 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(isTablet ? 6 : 4),
                                    color: index == _currentMediaIndex 
                                        ? Colors.white 
                                        : Colors.white.withOpacity(0.4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: isTablet ? 6 : 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: isTablet ? 24 : 16),

              // Editor Controls
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
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
                    children: [
                      // Tab Bar
                      Container(
                        margin: EdgeInsets.all(isTablet ? 16 : 12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: AppColors.textSecondary,
                          labelStyle: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w700,
                          ),
                          tabs: const [
                            Tab(text: 'Filter'),
                            Tab(text: 'Adjust'),
                            Tab(text: 'Crop'),
                          ],
                        ),
                      ),

                      // Tab Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Filters Tab
                            _buildComingSoonTab('Filter Grid', Icons.filter, isTablet),
                            // Adjustments Tab
                            _buildComingSoonTab('Adjustment Controls', Icons.tune, isTablet),
                            // Crop Tab
                            _buildComingSoonTab('Crop Editor', Icons.crop, isTablet),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: isTablet ? 24 : 16),
            ],
          );
        },
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
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
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
  
  Widget _buildComingSoonTab(String title, IconData icon, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient.scale(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: isTablet ? 48 : 40,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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