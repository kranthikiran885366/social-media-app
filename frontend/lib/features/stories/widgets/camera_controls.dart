import 'package:flutter/material.dart';

class CameraControls extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onCapturePhoto;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final AnimationController recordingAnimation;

  const CameraControls({
    Key? key,
    required this.isRecording,
    required this.onCapturePhoto,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.recordingAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery Button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.photo_library, color: Colors.white, size: 24),
            ),
          ),

          // Capture Button
          GestureDetector(
            onTap: isRecording ? onStopRecording : onCapturePhoto,
            onLongPress: isRecording ? null : onStartRecording,
            child: AnimatedBuilder(
              animation: recordingAnimation,
              builder: (context, child) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: isRecording ? 4 : 6,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: isRecording ? 30 : 60,
                      height: isRecording ? 30 : 60,
                      decoration: BoxDecoration(
                        color: isRecording ? Colors.red : Colors.white,
                        shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
                        borderRadius: isRecording ? BorderRadius.circular(4) : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Switch Camera Button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterSelector extends StatelessWidget {
  final Function(dynamic) onFilterSelected;
  final Function(dynamic) onARFilterSelected;

  const FilterSelector({
    Key? key,
    required this.onFilterSelected,
    required this.onARFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onFilterSelected({'id': index, 'name': 'Filter $index'}),
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.filter, color: Colors.white, size: 24),
                  const SizedBox(height: 4),
                  Text('Filter $index', style: const TextStyle(color: Colors.white, fontSize: 10)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ARFilterOverlay extends StatelessWidget {
  final dynamic filter;

  const ARFilterOverlay({Key? key, required this.filter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text('AR Filter Active', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class StoryTextEditor extends StatelessWidget {
  final Function(Map<String, dynamic>) onTextCreated;

  const StoryTextEditor({Key? key, required this.onTextCreated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const TextField(
            decoration: InputDecoration(labelText: 'Enter text...'),
            maxLines: 3,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              onTextCreated({'text': 'Sample text', 'color': 0xFFFFFFFF});
              Navigator.pop(context);
            },
            child: const Text('Add Text'),
          ),
        ],
      ),
    );
  }
}

class StoryDrawingCanvas extends StatelessWidget {
  final Function(Map<String, dynamic>) onDrawingComplete;

  const StoryDrawingCanvas({Key? key, required this.onDrawingComplete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => onDrawingComplete({'drawing': 'path_data'}),
        child: const Center(
          child: Text('Drawing Mode - Tap to finish', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class StoryMusicSelector extends StatelessWidget {
  final Function(Map<String, dynamic>) onMusicSelected;

  const StoryMusicSelector({Key? key, required this.onMusicSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Text('Choose Music', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text('Song $index'),
                  subtitle: Text('Artist $index'),
                  onTap: () {
                    onMusicSelected({
                      'title': 'Song $index',
                      'artist': 'Artist $index',
                      'url': 'music_url_$index',
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StoryTemplateSelector extends StatelessWidget {
  final Function(dynamic) onTemplateSelected;

  const StoryTemplateSelector({Key? key, required this.onTemplateSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Text('Templates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    onTemplateSelected({
                      'id': index,
                      'name': 'Template $index',
                      'layers': [],
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text('Template $index')),
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