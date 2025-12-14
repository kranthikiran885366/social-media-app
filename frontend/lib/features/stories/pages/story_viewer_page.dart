import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/story_models.dart';

class StoryViewerPage extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;

  const StoryViewerPage({
    Key? key,
    required this.stories,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  
  int _currentStoryIndex = 0;
  int _currentUserIndex = 0;
  bool _isPaused = false;
  
  List<List<Story>> _groupedStories = [];

  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _progressController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );
    
    _groupStories();
    _initializeStory();
  }

  void _groupStories() {
    Map<String, List<Story>> grouped = {};
    for (var story in widget.stories) {
      if (!grouped.containsKey(story.userId)) {
        grouped[story.userId] = [];
      }
      grouped[story.userId]!.add(story);
    }
    _groupedStories = grouped.values.toList();
  }

  void _initializeStory() {
    if (_groupedStories.isNotEmpty && _currentUserIndex < _groupedStories.length) {
      _startProgress();
    }
  }

  void _startProgress() {
    _progressController.reset();
    _progressController.forward().then((_) {
      if (!_isPaused) _nextStory();
    });
  }

  void _nextStory() {
    if (_currentStoryIndex < _groupedStories[_currentUserIndex].length - 1) {
      setState(() => _currentStoryIndex++);
      _initializeStory();
    } else {
      _nextUser();
    }
  }

  void _nextUser() {
    if (_currentUserIndex < _groupedStories.length - 1) {
      setState(() {
        _currentUserIndex++;
        _currentStoryIndex = 0;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_groupedStories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentUserIndex = index;
                _currentStoryIndex = 0;
              });
              _initializeStory();
            },
            itemCount: _groupedStories.length,
            itemBuilder: (context, userIndex) {
              final userStories = _groupedStories[userIndex];
              final currentStory = userStories[_currentStoryIndex];
              
              return GestureDetector(
                onTapDown: (details) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  if (details.localPosition.dx < screenWidth / 3) {
                    // Previous story
                  } else if (details.localPosition.dx > screenWidth * 2 / 3) {
                    _nextStory();
                  } else {
                    setState(() => _isPaused = !_isPaused);
                  }
                },
                child: Stack(
                  children: [
                    // Story Media
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: isTablet ? BorderRadius.circular(20) : null,
                        ),
                        child: ClipRRect(
                          borderRadius: isTablet ? BorderRadius.circular(20) : BorderRadius.zero,
                          child: Image.network(
                            currentStory.media.url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.backgroundSecondary,
                              child: Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: AppColors.textTertiary,
                                  size: isTablet ? 80 : 60,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Progress Indicators
                    Positioned(
                      top: MediaQuery.of(context).padding.top + (isTablet ? 16 : 8),
                      left: isTablet ? 24 : 12,
                      right: isTablet ? 24 : 12,
                      child: Row(
                        children: List.generate(userStories.length, (index) {
                          return Expanded(
                            child: Container(
                              height: isTablet ? 4 : 3,
                              margin: EdgeInsets.symmetric(
                                horizontal: isTablet ? 2 : 1,
                              ),
                              decoration: BoxDecoration(
                                gradient: index < _currentStoryIndex 
                                    ? AppColors.primaryGradient
                                    : null,
                                color: index < _currentStoryIndex 
                                    ? null
                                    : index == _currentStoryIndex
                                        ? Colors.white.withOpacity(0.8)
                                        : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(isTablet ? 2 : 1.5),
                                boxShadow: index <= _currentStoryIndex ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: isTablet ? 4 : 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ] : null,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // User Info
                    Positioned(
                      top: MediaQuery.of(context).padding.top + (isTablet ? 60 : 40),
                      left: isTablet ? 24 : 16,
                      right: isTablet ? 24 : 16,
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 16 : 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: isTablet ? 24 : 20,
                                backgroundImage: NetworkImage(currentStory.userAvatar),
                              ),
                            ),
                            SizedBox(width: isTablet ? 16 : 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentStory.username,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: isTablet ? 18 : 16,
                                    ),
                                  ),
                                  Text(
                                    '2h ago',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: isTablet ? 14 : 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: isTablet ? 28 : 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                // Story Elements
                ...currentStory.elements.map((element) => Positioned(
                  left: element.x * MediaQuery.of(context).size.width,
                  top: element.y * MediaQuery.of(context).size.height,
                  child: _buildElementWidget(element),
                )),

                    // Bottom Interactions
                    Positioned(
                      bottom: MediaQuery.of(context).padding.bottom + (isTablet ? 24 : 16),
                      left: isTablet ? 24 : 16,
                      right: isTablet ? 24 : 16,
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 16 : 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 20 : 16,
                                  vertical: isTablet ? 16 : 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                                ),
                                child: Text(
                                  'Send message',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(width: isTablet ? 16 : 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                              ),
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.favorite_border,
                                  color: Colors.white,
                                  size: isTablet ? 28 : 24,
                                ),
                              ),
                            ),
                            SizedBox(width: isTablet ? 8 : 4),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                              ),
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: isTablet ? 28 : 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildElementWidget(StoryElement element) {
    switch (element.type) {
      case ElementType.text:
        return Text(
          element.data['text'] ?? '',
          style: TextStyle(
            color: Color(element.data['color'] ?? 0xFFFFFFFF),
            fontSize: element.data['fontSize']?.toDouble() ?? 24,
          ),
        );
      case ElementType.sticker:
        return Text(element.data['emoji'] ?? '😀', style: const TextStyle(fontSize: 48));
      case ElementType.poll:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(element.data['question'] ?? 'Poll Question', 
                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Option 1', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      default:
        return Container();
    }
  }
}