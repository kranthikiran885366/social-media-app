import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/story_models.dart';
import '../widgets/highlight_cover_selector.dart';

class StoryHighlightsPage extends StatefulWidget {
  final String userId;

  const StoryHighlightsPage({super.key, required this.userId});

  @override
  State<StoryHighlightsPage> createState() => _StoryHighlightsPageState();
}

class _StoryHighlightsPageState extends State<StoryHighlightsPage> {
  List<StoryHighlight> _highlights = [];
  List<Story> _archivedStories = [];

  @override
  void initState() {
    super.initState();
    _loadHighlights();
    _loadArchivedStories();
  }

  void _loadHighlights() {
    // Load user's story highlights
    setState(() {
      _highlights = [
        StoryHighlight(
          id: '1',
          userId: widget.userId,
          title: 'Travel',
          coverUrl: 'https://example.com/cover1.jpg',
          storyIds: ['story1', 'story2'],
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        StoryHighlight(
          id: '2',
          userId: widget.userId,
          title: 'Food',
          coverUrl: 'https://example.com/cover2.jpg',
          storyIds: ['story3', 'story4', 'story5'],
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
    });
  }

  void _loadArchivedStories() {
    // Load archived stories
    setState(() {
      _archivedStories = List.generate(20, (index) => Story(
        id: 'archived_$index',
        userId: widget.userId,
        username: 'current_user',
        userAvatar: 'https://example.com/avatar.jpg',
        media: StoryMedia(
          url: 'https://example.com/story_$index.jpg',
          type: MediaType.photo,
          width: 1080,
          height: 1920,
        ),
        settings: const StorySettings(),
        createdAt: DateTime.now().subtract(Duration(days: index + 1)),
        expiresAt: DateTime.now().subtract(Duration(days: index)),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                floating: true,
                snap: true,
                expandedHeight: isTablet ? 120 : 100,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient.scale(0.1),
                    ),
                  ),
                  title: Text(
                    'Story Highlights',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isTablet ? 28 : 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  centerTitle: false,
                ),
                leading: Container(
                  margin: EdgeInsets.only(
                    left: isTablet ? 24 : 16,
                    top: isTablet ? 12 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                      size: isTablet ? 28 : 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: EdgeInsets.only(
                      right: isTablet ? 24 : 16,
                      top: isTablet ? 12 : 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    ),
                    child: IconButton(
                      onPressed: _createNewHighlight,
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: isTablet ? 28 : 24,
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Highlights Section
                    if (_highlights.isNotEmpty) ...[
                      Container(
                        margin: EdgeInsets.all(isTablet ? 24 : 16),
                        padding: EdgeInsets.all(isTablet ? 24 : 20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.05),
                              blurRadius: isTablet ? 15 : 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Highlights',
                                  style: TextStyle(
                                    fontSize: isTablet ? 22 : 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 16 : 12,
                                    vertical: isTablet ? 8 : 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                                  ),
                                  child: InkWell(
                                    onTap: _manageHighlights,
                                    child: Text(
                                      'Manage',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 14 : 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isTablet ? 20 : 16),
                            SizedBox(
                              height: isTablet ? 140 : 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _highlights.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == _highlights.length) {
                                    return _buildCreateHighlightButton(isTablet);
                                  }
                                  return _buildHighlightItem(_highlights[index], isTablet);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Archived Stories Section
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                        vertical: isTablet ? 16 : 12,
                      ),
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Archive',
                            style: TextStyle(
                              fontSize: isTablet ? 22 : 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.backgroundSecondary,
                              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                            ),
                            child: IconButton(
                              onPressed: () => _showArchiveOptions(),
                              icon: Icon(
                                Icons.more_vert,
                                color: AppColors.textSecondary,
                                size: isTablet ? 28 : 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              // Archive Grid
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 4 : 3,
                    crossAxisSpacing: isTablet ? 8 : 4,
                    mainAxisSpacing: isTablet ? 8 : 4,
                    childAspectRatio: 9 / 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildArchivedStoryItem(_archivedStories[index], isTablet);
                    },
                    childCount: _archivedStories.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHighlightItem(StoryHighlight highlight, bool isTablet) {
    return GestureDetector(
      onTap: () => _viewHighlight(highlight),
      onLongPress: () => _editHighlight(highlight),
      child: Container(
        width: isTablet ? 100 : 80,
        margin: EdgeInsets.only(right: isTablet ? 16 : 12),
        child: Column(
          children: [
            Container(
              width: isTablet ? 80 : 70,
              height: isTablet ? 80 : 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: isTablet ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    highlight.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.backgroundSecondary,
                      child: Icon(
                        Icons.photo,
                        color: AppColors.textTertiary,
                        size: isTablet ? 32 : 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              highlight.title,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateHighlightButton(bool isTablet) {
    return GestureDetector(
      onTap: _createNewHighlight,
      child: Container(
        width: isTablet ? 100 : 80,
        margin: EdgeInsets.only(right: isTablet ? 16 : 12),
        child: Column(
          children: [
            Container(
              width: isTablet ? 80 : 70,
              height: isTablet ? 80 : 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                color: AppColors.backgroundSecondary,
              ),
              child: Icon(
                Icons.add,
                color: AppColors.textSecondary,
                size: isTablet ? 36 : 30,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              'New',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchivedStoryItem(Story story, bool isTablet) {
    return GestureDetector(
      onTap: () => _viewArchivedStory(story),
      onLongPress: () => _showStoryOptions(story),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: isTablet ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                story.media.url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.backgroundSecondary,
                  child: Icon(
                    Icons.photo,
                    color: AppColors.textTertiary,
                    size: isTablet ? 32 : 24,
                  ),
                ),
              ),
              if (story.media.type == MediaType.video)
                Positioned(
                  top: isTablet ? 12 : 8,
                  right: isTablet ? 12 : 8,
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 6 : 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: isTablet ? 20 : 16,
                    ),
                  ),
                ),
              Positioned(
                bottom: isTablet ? 8 : 4,
                left: isTablet ? 8 : 4,
                right: isTablet ? 8 : 4,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 8 : 4,
                    vertical: isTablet ? 4 : 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(isTablet ? 8 : 4),
                  ),
                  child: Text(
                    _formatDate(story.createdAt),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 12 : 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewHighlight() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateHighlightSheet(
        archivedStories: _archivedStories,
        onHighlightCreated: (highlight) {
          setState(() => _highlights.add(highlight));
        },
      ),
    );
  }

  void _editHighlight(StoryHighlight highlight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditHighlightSheet(
        highlight: highlight,
        archivedStories: _archivedStories,
        onHighlightUpdated: (updatedHighlight) {
          setState(() {
            final index = _highlights.indexWhere((h) => h.id == updatedHighlight.id);
            if (index != -1) {
              _highlights[index] = updatedHighlight;
            }
          });
        },
        onHighlightDeleted: (highlightId) {
          setState(() => _highlights.removeWhere((h) => h.id == highlightId));
        },
      ),
    );
  }

  void _viewHighlight(StoryHighlight highlight) {
    // Navigate to highlight viewer
  }

  void _viewArchivedStory(Story story) {
    // Navigate to story viewer
  }

  void _showStoryOptions(Story story) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.highlight),
            title: const Text('Add to Highlight'),
            onTap: () {
              Navigator.pop(context);
              _addToHighlight(story);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share as Post'),
            onTap: () {
              Navigator.pop(context);
              _shareAsPost(story);
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Save to Gallery'),
            onTap: () {
              Navigator.pop(context);
              _saveToGallery(story);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteStory(story);
            },
          ),
        ],
      ),
    );
  }

  void _showArchiveOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.select_all),
            title: const Text('Select Multiple'),
            onTap: () {
              Navigator.pop(context);
              // Enable multi-select mode
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Save All to Gallery'),
            onTap: () {
              Navigator.pop(context);
              _saveAllToGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete All', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteAllArchived();
            },
          ),
        ],
      ),
    );
  }

  void _manageHighlights() {
    // Navigate to highlight management page
  }

  void _addToHighlight(Story story) {
    // Show highlight selection dialog
  }

  void _shareAsPost(Story story) {
    // Share story as regular post
  }

  void _saveToGallery(Story story) {
    // Save story to device gallery
  }

  void _deleteStory(Story story) {
    setState(() => _archivedStories.removeWhere((s) => s.id == story.id));
  }

  void _saveAllToGallery() {
    // Save all archived stories to gallery
  }

  void _deleteAllArchived() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Stories'),
        content: const Text('Are you sure you want to delete all archived stories? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _archivedStories.clear());
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}

class CreateHighlightSheet extends StatefulWidget {
  final List<Story> archivedStories;
  final Function(StoryHighlight) onHighlightCreated;

  const CreateHighlightSheet({
    Key? key,
    required this.archivedStories,
    required this.onHighlightCreated,
  }) : super(key: key);

  @override
  State<CreateHighlightSheet> createState() => _CreateHighlightSheetState();
}

class _CreateHighlightSheetState extends State<CreateHighlightSheet> {
  final TextEditingController _titleController = TextEditingController();
  List<Story> _selectedStories = [];
  String _selectedCover = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                const Text('New Highlight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: _selectedStories.isNotEmpty ? _createHighlight : null,
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
          
          // Title Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Highlight name',
                border: OutlineInputBorder(),
              ),
              maxLength: 30,
            ),
          ),
          
          // Cover Selection
          if (_selectedStories.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Choose Cover', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _selectedStories.length,
                itemBuilder: (context, index) {
                  final story = _selectedStories[index];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCover = story.media.url),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedCover == story.media.url ? Colors.blue : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(story.media.url, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          
          // Story Selection
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Select Stories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 9 / 16,
              ),
              itemCount: widget.archivedStories.length,
              itemBuilder: (context, index) {
                final story = widget.archivedStories[index];
                final isSelected = _selectedStories.contains(story);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedStories.remove(story);
                      } else {
                        _selectedStories.add(story);
                      }
                      if (_selectedStories.isNotEmpty && _selectedCover.isEmpty) {
                        _selectedCover = _selectedStories.first.media.url;
                      }
                    });
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(story.media.url, fit: BoxFit.cover),
                      ),
                      if (isSelected)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.check_circle, color: Colors.white),
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

  void _createHighlight() {
    if (_titleController.text.isNotEmpty && _selectedStories.isNotEmpty) {
      final highlight = StoryHighlight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user_id',
        title: _titleController.text,
        coverUrl: _selectedCover,
        storyIds: _selectedStories.map((s) => s.id).toList(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      widget.onHighlightCreated(highlight);
      Navigator.pop(context);
    }
  }
}

class EditHighlightSheet extends StatefulWidget {
  final StoryHighlight highlight;
  final List<Story> archivedStories;
  final Function(StoryHighlight) onHighlightUpdated;
  final Function(String) onHighlightDeleted;

  const EditHighlightSheet({
    Key? key,
    required this.highlight,
    required this.archivedStories,
    required this.onHighlightUpdated,
    required this.onHighlightDeleted,
  }) : super(key: key);

  @override
  State<EditHighlightSheet> createState() => _EditHighlightSheetState();
}

class _EditHighlightSheetState extends State<EditHighlightSheet> {
  late TextEditingController _titleController;
  late List<String> _selectedStoryIds;
  late String _selectedCover;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.highlight.title);
    _selectedStoryIds = List.from(widget.highlight.storyIds);
    _selectedCover = widget.highlight.coverUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                const Text('Edit Highlight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: _deleteHighlight,
                      child: const Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Highlight', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Title Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Highlight name',
                border: OutlineInputBorder(),
              ),
              maxLength: 30,
            ),
          ),
          
          // Save Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    final updatedHighlight = StoryHighlight(
      id: widget.highlight.id,
      userId: widget.highlight.userId,
      title: _titleController.text,
      coverUrl: _selectedCover,
      storyIds: _selectedStoryIds,
      createdAt: widget.highlight.createdAt,
      updatedAt: DateTime.now(),
    );
    
    widget.onHighlightUpdated(updatedHighlight);
    Navigator.pop(context);
  }

  void _deleteHighlight() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Highlight'),
        content: const Text('Are you sure you want to delete this highlight?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onHighlightDeleted(widget.highlight.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}