import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../models/post_models.dart';

class EnhancedPostEditorPage extends StatefulWidget {
  final List<XFile> mediaFiles;
  final bool isCarousel;
  final Function(List<PostMedia>) onEditComplete;

  const EnhancedPostEditorPage({
    Key? key,
    required this.mediaFiles,
    required this.isCarousel,
    required this.onEditComplete,
  }) : super(key: key);

  @override
  State<EnhancedPostEditorPage> createState() => _EnhancedPostEditorPageState();
}

class _EnhancedPostEditorPageState extends State<EnhancedPostEditorPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  late AnimationController _filterAnimationController;
  
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
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
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
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Media Preview Section
          Expanded(
            flex: 3,
            child: _buildMediaPreviewSection(),
          ),

          // Editor Controls Section
          Expanded(
            flex: 2,
            child: _buildEditorControlsSection(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      title: const Text(
        'Edit Post',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton(
            onPressed: _saveEdits,
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPreviewSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // Media PageView
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
              top: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_editedMedia.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: index == _currentMediaIndex ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: index == _currentMediaIndex 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.4),
                    ),
                  );
                }),
              ),
            ),

          // Filter Preview Overlay
          if (_selectedFilter != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: _getFilterGradient(_selectedFilter!),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(PostMedia media) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: media.type == MediaType.video
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_filled_rounded,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                  ),
                  // Video preview would go here
                ],
              )
            : Image.file(
                File(media.url),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
      ),
    );
  }

  Widget _buildEditorControlsSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[900]!,
            Colors.black,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[400],
              indicator: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.filter_vintage_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Filter', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.tune_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Adjust', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.crop_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Crop', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFiltersTab(),
                _buildAdjustmentsTab(),
                _buildCropTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersTab() {
    final filters = [
      PostFilter(name: 'Original', intensity: 0.0),
      PostFilter(name: 'Vintage', intensity: 0.8),
      PostFilter(name: 'Dramatic', intensity: 0.9),
      PostFilter(name: 'Bright', intensity: 0.7),
      PostFilter(name: 'Warm', intensity: 0.6),
      PostFilter(name: 'Cool', intensity: 0.5),
      PostFilter(name: 'Noir', intensity: 1.0),
      PostFilter(name: 'Vivid', intensity: 0.8),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Filter',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = _selectedFilter?.name == filter.name;
                
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedFilter = filter);
                    _applyFilter(filter);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey[600]!,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ] : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: _getFilterGradient(filter),
                            ),
                            child: Image.file(
                              File(_editedMedia[_currentMediaIndex].url),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        filter.name,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : Colors.grey[400],
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentsTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adjust Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildAdjustmentSlider(
                  'Brightness',
                  Icons.brightness_6_rounded,
                  _adjustments.brightness,
                  (value) => setState(() => _adjustments = _adjustments.copyWith(brightness: value)),
                ),
                _buildAdjustmentSlider(
                  'Contrast',
                  Icons.contrast_rounded,
                  _adjustments.contrast,
                  (value) => setState(() => _adjustments = _adjustments.copyWith(contrast: value)),
                ),
                _buildAdjustmentSlider(
                  'Saturation',
                  Icons.palette_rounded,
                  _adjustments.saturation,
                  (value) => setState(() => _adjustments = _adjustments.copyWith(saturation: value)),
                ),
                _buildAdjustmentSlider(
                  'Warmth',
                  Icons.wb_sunny_rounded,
                  _adjustments.warmth,
                  (value) => setState(() => _adjustments = _adjustments.copyWith(warmth: value)),
                ),
                _buildAdjustmentSlider(
                  'Vignette',
                  Icons.vignette_rounded,
                  _adjustments.vignette,
                  (value) => setState(() => _adjustments = _adjustments.copyWith(vignette: value)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentSlider(
    String label,
    IconData icon,
    double value,
    Function(double) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.grey[600],
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              onChanged: (newValue) {
                HapticFeedback.selectionClick();
                onChanged(newValue);
                _applyAdjustments(_adjustments);
              },
              min: 0.0,
              max: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crop & Rotate',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildCropOption('Original', '1:1', Icons.crop_original_rounded),
                _buildCropOption('Square', '1:1', Icons.crop_square_rounded),
                _buildCropOption('Portrait', '4:5', Icons.crop_portrait_rounded),
                _buildCropOption('Landscape', '16:9', Icons.crop_landscape_rounded),
                _buildCropOption('Story', '9:16', Icons.crop_free_rounded),
                _buildCropOption('Free', 'Free', Icons.crop_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropOption(String name, String ratio, IconData icon) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        // Apply crop ratio
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[600]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              ratio,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient? _getFilterGradient(PostFilter filter) {
    switch (filter.name) {
      case 'Vintage':
        return LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.3),
            Colors.brown.withOpacity(0.2),
          ],
        );
      case 'Dramatic':
        return LinearGradient(
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.purple.withOpacity(0.2),
          ],
        );
      case 'Bright':
        return LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.yellow.withOpacity(0.1),
          ],
        );
      case 'Warm':
        return LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.2),
            Colors.red.withOpacity(0.1),
          ],
        );
      case 'Cool':
        return LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.2),
            Colors.cyan.withOpacity(0.1),
          ],
        );
      case 'Noir':
        return LinearGradient(
          colors: [
            Colors.black.withOpacity(0.5),
            Colors.grey.withOpacity(0.3),
          ],
        );
      case 'Vivid':
        return LinearGradient(
          colors: [
            Colors.pink.withOpacity(0.2),
            Colors.purple.withOpacity(0.2),
          ],
        );
      default:
        return null;
    }
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
    HapticFeedback.lightImpact();
    widget.onEditComplete(_editedMedia);
  }
}