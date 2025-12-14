import 'package:flutter/material.dart';
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
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
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
                  child: Image.network(currentStory.media.url, fit: BoxFit.cover),
                ),

                // Progress Indicators
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    children: List.generate(userStories.length, (index) {
                      return Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: index < _currentStoryIndex 
                                ? Colors.white 
                                : index == _currentStoryIndex
                                    ? Colors.white70
                                    : Colors.white30,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // User Info
                Positioned(
                  top: MediaQuery.of(context).padding.top + 40,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(currentStory.userAvatar),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentStory.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '2h ago',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
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
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Text(
                            'Send message',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.send, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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