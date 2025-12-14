import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../models/story_models.dart';
import '../widgets/story_stickers.dart';
import '../widgets/story_text_editor.dart';
import '../widgets/story_drawing_tools.dart';
import '../widgets/story_music_selector.dart';
import '../widgets/story_templates.dart';

class StoryEditorPage extends StatefulWidget {
  final String mediaPath;
  final MediaType mediaType;
  final CameraFilter? selectedFilter;
  final ARFilter? selectedARFilter;

  const StoryEditorPage({
    super.key,
    required this.mediaPath,
    required this.mediaType,
    this.selectedFilter,
    this.selectedARFilter,
  });

  @override
  State<StoryEditorPage> createState() => _StoryEditorPageState();
}

class _StoryEditorPageState extends State<StoryEditorPage>
    with TickerProviderStateMixin {
  List<StoryElement> _elements = [];
  StoryElement? _selectedElement;
  bool _isDrawingMode = false;
  bool _isTextMode = false;
  String? _selectedMusic;
  StoryTemplate? _selectedTemplate;
  
  late AnimationController _elementAnimationController;
  
  @override
  void initState() {
    super.initState();
    _elementAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _elementAnimationController.dispose();
    super.dispose();
  }

  void _addElement(StoryElement element) {
    setState(() {
      _elements.add(element);
      _selectedElement = element;
    });
    _elementAnimationController.forward();
  }

  void _updateElement(StoryElement updatedElement) {
    setState(() {
      final index = _elements.indexWhere((e) => e.id == updatedElement.id);
      if (index != -1) {
        _elements[index] = updatedElement;
      }
    });
  }

  void _removeElement(String elementId) {
    setState(() {
      _elements.removeWhere((e) => e.id == elementId);
      if (_selectedElement?.id == elementId) {
        _selectedElement = null;
      }
    });
  }

  void _showStickerSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StoryStickerSelector(
        onStickerSelected: (stickerData) {
          _addElement(StoryElement(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: ElementType.sticker,
            x: 0.5,
            y: 0.5,
            width: 0.2,
            height: 0.2,
            data: stickerData,
            timestamp: DateTime.now(),
          ));
        },
        onPollCreated: (pollData) {
          _addElement(StoryElement(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: ElementType.poll,
            x: 0.5,
            y: 0.7,
            width: 0.8,
            height: 0.15,
            data: pollData,
            timestamp: DateTime.now(),
          ));
        },
        onQuestionCreated: (questionData) {
          _addElement(StoryElement(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: ElementType.question,
            x: 0.5,
            y: 0.7,
            width: 0.8,
            height: 0.15,
            data: questionData,
            timestamp: DateTime.now(),
          ));
        },
        onQuizCreated: (quizData) {
          _addElement(StoryElement(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: ElementType.quiz,
            x: 0.5,
            y: 0.7,
            width: 0.8,
            height: 0.2,
            data: quizData,
            timestamp: DateTime.now(),
          ));
        },
        onEmojiSliderCreated: (sliderData) {
          _addElement(StoryElement(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: ElementType.emojiSlider,
            x: 0.5,
            y: 0.7,
            width: 0.8,
            height: 0.1,
            data: sliderData,
            timestamp: DateTime.now(),
          ));
        },
        onCountdownCreated: (countdownData) {
          _addElement(StoryElement(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: ElementType.countdown,
            x: 0.5,
            y: 0.5,
            width: 0.6,
            height: 0.3,
            data: countdownData,
            timestamp: DateTime.now(),
          ));
        },
      ),
    );
  }

  void _showTextEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StoryTextEditor(
        onTextCreated: (textData) {
          _addElement(StoryElement(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: ElementType.text,
            x: 0.5,
            y: 0.5,
            width: 0.8,
            height: 0.1,
            data: textData,
            timestamp: DateTime.now(),
          ));
        },
      ),
    );
  }

  void _showMusicSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StoryMusicSelector(
        onMusicSelected: (musicData) {
          setState(() => _selectedMusic = musicData['url']);
          _addElement(StoryElement(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: ElementType.music,
            x: 0.1,
            y: 0.1,
            width: 0.3,
            height: 0.08,
            data: musicData,
            timestamp: DateTime.now(),
          ));
        },
      ),
    );
  }

  void _showTemplateSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StoryTemplateSelector(
        onTemplateSelected: (template) {
          setState(() => _selectedTemplate = template);
          // Apply template layers as elements
          for (final layer in template.layers) {
            _addElement(StoryElement(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: ElementType.values.firstWhere(
                (e) => e.name == layer.type,
                orElse: () => ElementType.sticker,
              ),
              x: layer.x,
              y: layer.y,
              width: layer.width,
              height: layer.height,
              data: layer.properties,
              timestamp: DateTime.now(),
            ));
          }
        },
      ),
    );
  }

  void _addLocation() {
    // Show location picker
    _addElement(StoryElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ElementType.location,
      x: 0.5,
      y: 0.9,
      width: 0.6,
      height: 0.08,
      data: {
        'name': 'Current Location',
        'latitude': 0.0,
        'longitude': 0.0,
      },
      timestamp: DateTime.now(),
    ));
  }

  void _addHashtag() {
    _addElement(StoryElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ElementType.hashtag,
      x: 0.5,
      y: 0.8,
      width: 0.4,
      height: 0.06,
      data: {'text': '#hashtag'},
      timestamp: DateTime.now(),
    ));
  }

  void _addMention() {
    _addElement(StoryElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ElementType.mention,
      x: 0.5,
      y: 0.8,
      width: 0.4,
      height: 0.06,
      data: {'username': '@username'},
      timestamp: DateTime.now(),
    ));
  }

  void _addTimeWeather() {
    _addElement(StoryElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ElementType.timeWeather,
      x: 0.1,
      y: 0.1,
      width: 0.25,
      height: 0.1,
      data: {
        'time': DateTime.now().toString(),
        'weather': '22°C Sunny',
        'location': 'Current Location',
      },
      timestamp: DateTime.now(),
    ));
  }

  void _publishStory() {
    // Create story object and publish
    final story = Story(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id',
      username: 'current_username',
      userAvatar: 'avatar_url',
      media: StoryMedia(
        url: widget.mediaPath,
        type: widget.mediaType,
        width: 1080,
        height: 1920,
        musicUrl: _selectedMusic,
      ),
      elements: _elements,
      settings: const StorySettings(),
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );

    // TODO: Implement story publishing logic
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media Background
          Positioned.fill(
            child: widget.mediaType == MediaType.photo
                ? Image.file(File(widget.mediaPath), fit: BoxFit.cover)
                : Container(), // Video player would go here
          ),

          // Story Elements Overlay
          Positioned.fill(
            child: Stack(
              children: _elements.map((element) => _buildStoryElement(element)).toList(),
            ),
          ),

          // Drawing Canvas
          if (_isDrawingMode)
            Positioned.fill(
              child: StoryDrawingCanvas(
                onDrawingComplete: (drawingData) {
                  _addElement(StoryElement(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    type: ElementType.drawing,
                    x: 0,
                    y: 0,
                    width: 1,
                    height: 1,
                    data: drawingData,
                    timestamp: DateTime.now(),
                  ));
                  setState(() => _isDrawingMode = false);
                },
              ),
            ),

          // Top Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _showTemplateSelector,
                      icon: const Icon(Icons.auto_awesome, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: _addTimeWeather,
                      icon: const Icon(Icons.schedule, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Side Tools
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              children: [
                _buildToolButton(Icons.text_fields, _showTextEditor),
                const SizedBox(height: 16),
                _buildToolButton(Icons.brush, () => setState(() => _isDrawingMode = true)),
                const SizedBox(height: 16),
                _buildToolButton(Icons.face_retouching_natural, _showStickerSelector),
                const SizedBox(height: 16),
                _buildToolButton(Icons.music_note, _showMusicSelector),
                const SizedBox(height: 16),
                _buildToolButton(Icons.location_on, _addLocation),
                const SizedBox(height: 16),
                _buildToolButton(Icons.tag, _addHashtag),
                const SizedBox(height: 16),
                _buildToolButton(Icons.alternate_email, _addMention),
              ],
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Save Draft', style: TextStyle(color: Colors.white)),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Close Friends', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _publishStory,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.pink],
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Text(
                          'Share',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, VoidCallback onTap, bool isTablet) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isTablet ? 56 : 44,
        height: isTablet ? 56 : 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: isTablet ? 8 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isTablet ? 28 : 24,
        ),
      ),
    );
  }

  Widget _buildStoryElement(StoryElement element) {
    return Positioned(
      left: element.x * MediaQuery.of(context).size.width,
      top: element.y * MediaQuery.of(context).size.height,
      child: GestureDetector(
        onTap: () => setState(() => _selectedElement = element),
        onPanUpdate: (details) {
          final newX = (element.x * MediaQuery.of(context).size.width + details.delta.dx) / 
                      MediaQuery.of(context).size.width;
          final newY = (element.y * MediaQuery.of(context).size.height + details.delta.dy) / 
                      MediaQuery.of(context).size.height;
          
          _updateElement(element.copyWith(x: newX, y: newY));
        },
        child: Transform.rotate(
          angle: element.rotation,
          child: Transform.scale(
            scale: element.scale,
            child: Container(
              width: element.width * MediaQuery.of(context).size.width,
              height: element.height * MediaQuery.of(context).size.height,
              decoration: _selectedElement?.id == element.id
                  ? BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: _buildElementContent(element),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElementContent(StoryElement element) {
    switch (element.type) {
      case ElementType.text:
        return Text(
          element.data['text'] ?? '',
          style: TextStyle(
            color: Color(element.data['color'] ?? 0xFFFFFFFF),
            fontSize: element.data['fontSize']?.toDouble() ?? 24,
            fontWeight: element.data['bold'] == true ? FontWeight.bold : FontWeight.normal,
          ),
        );
      case ElementType.sticker:
        return Image.network(element.data['url'] ?? '', fit: BoxFit.contain);
      case ElementType.poll:
        return _buildPollSticker(element.data);
      case ElementType.question:
        return _buildQuestionSticker(element.data);
      case ElementType.quiz:
        return _buildQuizSticker(element.data);
      case ElementType.emojiSlider:
        return _buildEmojiSlider(element.data);
      case ElementType.countdown:
        return _buildCountdownSticker(element.data);
      case ElementType.music:
        return _buildMusicSticker(element.data);
      case ElementType.location:
        return _buildLocationSticker(element.data);
      case ElementType.hashtag:
        return Text(element.data['text'] ?? '#hashtag', 
                   style: const TextStyle(color: Colors.blue, fontSize: 16));
      case ElementType.mention:
        return Text(element.data['username'] ?? '@username', 
                   style: const TextStyle(color: Colors.blue, fontSize: 16));
      case ElementType.timeWeather:
        return _buildTimeWeatherSticker(element.data);
      default:
        return Container();
    }
  }

  Widget _buildPollSticker(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(data['question'] ?? 'Poll Question', 
               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...List.generate(2, (index) => Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(data['options']?[index] ?? 'Option ${index + 1}',
                       style: const TextStyle(color: Colors.white)),
          )),
        ],
      ),
    );
  }

  Widget _buildQuestionSticker(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.purple.shade400, Colors.pink.shade400]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.help_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(data['placeholder'] ?? 'Ask me a question',
                       style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizSticker(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(data['question'] ?? 'Quiz Question',
               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...List.generate(data['options']?.length ?? 2, (index) => Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(data['options']?[index] ?? 'Option ${index + 1}',
                       style: const TextStyle(color: Colors.white, fontSize: 12)),
          )),
        ],
      ),
    );
  }

  Widget _buildEmojiSlider(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Text(data['emoji'] ?? '😍', style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(data['emoji'] ?? '😍', style: const TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildCountdownSticker(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.red.shade400, Colors.orange.shade400]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(data['title'] ?? 'Countdown',
               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('00:00:00', style: TextStyle(color: Colors.white, fontSize: 24)),
          Text(data['endDate'] ?? 'End Date',
               style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMusicSticker(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.music_note, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text('${data['title']} • ${data['artist']}',
               style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLocationSticker(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(data['name'] ?? 'Location',
               style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTimeWeatherSticker(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['time'] ?? DateTime.now().toString().substring(11, 16),
               style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          Text(data['weather'] ?? '22°C',
               style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

extension StoryElementExtension on StoryElement {
  StoryElement copyWith({
    String? id,
    ElementType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    double? scale,
    Map<String, dynamic>? data,
    DateTime? timestamp,
  }) {
    return StoryElement(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}