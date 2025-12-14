import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class ARFiltersPage extends StatefulWidget {
  const ARFiltersPage({super.key});

  @override
  State<ARFiltersPage> createState() => _ARFiltersPageState();
}

class _ARFiltersPageState extends State<ARFiltersPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  int _selectedFilterIndex = -1;
  bool _isRecording = false;
  bool _isFrontCamera = true;

  final List<ARFilter> _filters = [
    ARFilter(
      id: '1',
      name: 'Sparkles',
      thumbnail: 'assets/filters/sparkles.png',
      category: 'Beauty',
      isPopular: true,
    ),
    ARFilter(
      id: '2',
      name: 'Cat Ears',
      thumbnail: 'assets/filters/cat_ears.png',
      category: 'Fun',
      isPopular: false,
    ),
    ARFilter(
      id: '3',
      name: 'Rainbow',
      thumbnail: 'assets/filters/rainbow.png',
      category: 'Effects',
      isPopular: true,
    ),
    ARFilter(
      id: '4',
      name: 'Vintage',
      thumbnail: 'assets/filters/vintage.png',
      category: 'Retro',
      isPopular: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildCameraPreview(),
          _buildTopControls(),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.8),
            AppColors.primary.withOpacity(0.3),
            Colors.black.withOpacity(0.9),
          ],
        ),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[900],
            child: const Center(
              child: Icon(
                Icons.camera_alt_rounded,
                size: 100,
                color: Colors.white30,
              ),
            ),
          ),
          if (_selectedFilterIndex >= 0) _buildFilterOverlay(),
        ],
      ),
    );
  }

  Widget _buildFilterOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            _getFilterColor().withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _filters[_selectedFilterIndex].name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isFrontCamera ? Icons.camera_front_rounded : Icons.camera_rear_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isFrontCamera = !_isFrontCamera;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings_rounded, color: Colors.white),
                    onPressed: _showSettings,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.view_in_ar_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'AR Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    _buildRecordButton(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicator: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Beauty'),
                    Tab(text: 'Fun'),
                    Tab(text: 'Effects'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFiltersGrid(_filters),
                    _buildFiltersGrid(_filters.where((f) => f.category == 'Beauty').toList()),
                    _buildFiltersGrid(_filters.where((f) => f.category == 'Fun').toList()),
                    _buildFiltersGrid(_filters.where((f) => f.category == 'Effects').toList()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        setState(() {
          _isRecording = !_isRecording;
        });
        if (_isRecording) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isRecording ? _scaleAnimation.value : 1.0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: _isRecording ? null : AppColors.primaryGradient,
                color: _isRecording ? Colors.red : null,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.red : AppColors.primary).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop_rounded : Icons.fiber_manual_record_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltersGrid(List<ARFilter> filters) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: filters.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildNoFilterOption();
        }
        
        final filter = filters[index - 1];
        final filterIndex = _filters.indexOf(filter);
        final isSelected = _selectedFilterIndex == filterIndex;
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedFilterIndex = isSelected ? -1 : filterIndex;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _getFilterGradient(filter),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            _getFilterIcon(filter),
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        if (filter.isPopular)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: AppColors.secondaryGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Popular',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.backgroundSecondary,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                  ),
                  child: Text(
                    filter.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoFilterOption() {
    final isSelected = _selectedFilterIndex == -1;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedFilterIndex = -1;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.no_photography_rounded,
                    size: 40,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.backgroundSecondary,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              ),
              child: Text(
                'No Filter',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getFilterGradient(ARFilter filter) {
    switch (filter.category) {
      case 'Beauty':
        return LinearGradient(
          colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.7)],
        );
      case 'Fun':
        return LinearGradient(
          colors: [AppColors.accent, AppColors.accent.withOpacity(0.7)],
        );
      case 'Effects':
        return LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
        );
      default:
        return LinearGradient(
          colors: [AppColors.warning, AppColors.warning.withOpacity(0.7)],
        );
    }
  }

  IconData _getFilterIcon(ARFilter filter) {
    switch (filter.name) {
      case 'Sparkles':
        return Icons.auto_awesome_rounded;
      case 'Cat Ears':
        return Icons.pets_rounded;
      case 'Rainbow':
        return Icons.palette_rounded;
      case 'Vintage':
        return Icons.filter_vintage_rounded;
      default:
        return Icons.filter_rounded;
    }
  }

  Color _getFilterColor() {
    if (_selectedFilterIndex < 0) return Colors.transparent;
    
    final filter = _filters[_selectedFilterIndex];
    switch (filter.category) {
      case 'Beauty':
        return AppColors.secondary;
      case 'Fun':
        return AppColors.accent;
      case 'Effects':
        return AppColors.primary;
      default:
        return AppColors.warning;
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Filter Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.download_rounded),
              title: const Text('Download More Filters'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.create_rounded),
              title: const Text('Create Custom Filter'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ARFilter {
  final String id;
  final String name;
  final String thumbnail;
  final String category;
  final bool isPopular;

  ARFilter({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.category,
    required this.isPopular,
  });
}