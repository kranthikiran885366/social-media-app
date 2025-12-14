import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../bloc/reels_bloc.dart';
import '../../data/models/reel_model.dart';

class ReelsEditorPage extends StatefulWidget {
  final String videoPath;

  const ReelsEditorPage({super.key, required this.videoPath});

  @override
  State<ReelsEditorPage> createState() => _ReelsEditorPageState();
}

class _ReelsEditorPageState extends State<ReelsEditorPage>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  late TabController _tabController;
  
  double _startTime = 0.0;
  double _endTime = 30.0;
  double _currentSpeed = 1.0;
  double _volume = 1.0;
  
  ReelAudio? _selectedAudio;
  List<ReelEffect> _appliedEffects = [];
  String _caption = '';
  List<String> _hashtags = [];
  List<String> _mentions = [];
  String? _location;
  
  final TextEditingController _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _initializeVideo();
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {
          _endTime = _videoController!.value.duration.inSeconds.toDouble();
        });
        _videoController!.play();
        _videoController!.setLooping(true);
      });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _tabController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<ReelsBloc, ReelsState>(
        listener: (context, state) {
          if (state is VideoTrimmed) {
            _updateVideoPath(state.trimmedPath);
          } else if (state is SpeedChanged) {
            _updateVideoSpeed(state.speed);
          } else if (state is AudioAdded) {
            setState(() {
              _selectedAudio = state.audio;
            });
          } else if (state is EffectAdded) {
            setState(() {
              _appliedEffects.add(state.effect);
            });
          } else if (state is ReelPublished) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              flex: 3,
              child: _buildVideoPreview(),
            ),
            _buildTimelineEditor(),
            Expanded(
              flex: 2,
              child: _buildEditingTabs(),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Text(
              'Edit Reel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _saveDraft,
              child: const Text(
                'Draft',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Stack(
            children: [
              VideoPlayer(_videoController!),
              _buildVideoOverlays(),
              _buildPlayPauseButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoOverlays() {
    return Stack(
      children: [
        // Speed indicator
        if (_currentSpeed != 1.0)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentSpeed}x',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        
        // Audio indicator
        if (_selectedAudio != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedAudio!.title,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlayPauseButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_videoController!.value.isPlaying) {
              _videoController!.pause();
            } else {
              _videoController!.play();
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineEditor() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${_startTime.toInt()}s',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Expanded(
                child: RangeSlider(
                  values: RangeValues(_startTime, _endTime),
                  min: 0,
                  max: _videoController?.value.duration.inSeconds.toDouble() ?? 30,
                  divisions: 30,
                  onChanged: (values) {
                    setState(() {
                      _startTime = values.start;
                      _endTime = values.end;
                    });
                  },
                  onChangeEnd: (values) {
                    context.read<ReelsBloc>().add(TrimVideo(
                      videoPath: widget.videoPath,
                      startTime: values.start,
                      endTime: values.end,
                    ));
                  },
                ),
              ),
              Text(
                '${_endTime.toInt()}s',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Video Timeline',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditingTabs() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Audio'),
            Tab(text: 'Effects'),
            Tab(text: 'Speed'),
            Tab(text: 'Text'),
            Tab(text: 'Stickers'),
            Tab(text: 'More'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAudioTab(),
              _buildEffectsTab(),
              _buildSpeedTab(),
              _buildTextTab(),
              _buildStickersTab(),
              _buildMoreTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showMusicLibrary,
                  icon: const Icon(Icons.library_music),
                  label: const Text('Music Library'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _recordVoiceOver,
                  icon: const Icon(Icons.mic),
                  label: const Text('Voice Over'),
                ),
              ),
            ],
          ),
        ),
        if (_selectedAudio != null) ...[
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(_selectedAudio!.coverUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(_selectedAudio!.title, style: const TextStyle(color: Colors.white)),
            subtitle: Text(_selectedAudio!.artist, style: const TextStyle(color: Colors.white70)),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _selectedAudio = null;
                });
              },
            ),
          ),
          Slider(
            value: _volume,
            onChanged: (value) {
              setState(() {
                _volume = value;
              });
            },
            label: 'Volume: ${(_volume * 100).toInt()}%',
          ),
        ],
      ],
    );
  }

  Widget _buildEffectsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _applyEffect(index),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getEffectIcon(index),
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  'Effect ${index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeedTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Playback Speed',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [0.3, 0.5, 1.0, 1.5, 2.0, 3.0].map((speed) {
              return ChoiceChip(
                label: Text('${speed}x'),
                selected: _currentSpeed == speed,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _currentSpeed = speed;
                    });
                    context.read<ReelsBloc>().add(ChangeSpeed(
                      videoPath: widget.videoPath,
                      speed: speed,
                    ));
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addText,
                  icon: const Icon(Icons.text_fields),
                  label: const Text('Add Text'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _generateCaptions,
                  icon: const Icon(Icons.closed_caption),
                  label: const Text('Auto Captions'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _textToSpeech,
            icon: const Icon(Icons.record_voice_over),
            label: const Text('Text to Speech'),
          ),
        ],
      ),
    );
  }

  Widget _buildStickersTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _addSticker(index),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '😀',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoreTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.location_on, color: Colors.white),
          title: const Text('Add Location', style: TextStyle(color: Colors.white)),
          onTap: _addLocation,
        ),
        ListTile(
          leading: const Icon(Icons.person_add, color: Colors.white),
          title: const Text('Tag People', style: TextStyle(color: Colors.white)),
          onTap: _tagPeople,
        ),
        ListTile(
          leading: const Icon(Icons.face_retouching_natural, color: Colors.white),
          title: const Text('Beauty Filter', style: TextStyle(color: Colors.white)),
          onTap: _applyBeautyFilter,
        ),
        ListTile(
          leading: const Icon(Icons.view_in_ar, color: Colors.white),
          title: const Text('AR Effects', style: TextStyle(color: Colors.white)),
          onTap: _showAREffects,
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _captionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Write a caption...',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              maxLines: 3,
              minLines: 1,
              onChanged: (value) {
                _caption = value;
                _extractHashtagsAndMentions(value);
              },
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _publishReel,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _updateVideoPath(String newPath) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.asset(newPath)
      ..initialize().then((_) {
        setState(() {});
        _videoController!.play();
        _videoController!.setLooping(true);
      });
  }

  void _updateVideoSpeed(double speed) {
    _videoController?.setPlaybackSpeed(speed);
  }

  void _showMusicLibrary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MusicLibrarySheet(
        onAudioSelected: (audio) {
          context.read<ReelsBloc>().add(AddAudio(
            videoPath: widget.videoPath,
            audio: audio,
          ));
        },
      ),
    );
  }

  void _recordVoiceOver() {
    // Implement voice over recording
  }

  void _applyEffect(int effectIndex) {
    final effect = ReelEffect(
      id: 'effect_$effectIndex',
      name: 'Effect ${effectIndex + 1}',
      type: 'visual',
      parameters: {},
    );
    
    context.read<ReelsBloc>().add(AddEffect(
      videoPath: widget.videoPath,
      effect: effect,
    ));
  }

  void _addText() {
    // Implement text overlay
  }

  void _generateCaptions() {
    context.read<ReelsBloc>().add(GenerateAutoCaptions(widget.videoPath));
  }

  void _textToSpeech() {
    // Implement text to speech
  }

  void _addSticker(int stickerIndex) {
    context.read<ReelsBloc>().add(AddSticker(
      videoPath: widget.videoPath,
      stickerId: 'sticker_$stickerIndex',
      x: 0.5,
      y: 0.5,
    ));
  }

  void _addLocation() {
    // Implement location picker
  }

  void _tagPeople() {
    // Implement people tagging
  }

  void _applyBeautyFilter() {
    // Implement beauty filter
  }

  void _showAREffects() {
    // Implement AR effects
  }

  void _extractHashtagsAndMentions(String text) {
    final hashtagRegex = RegExp(r'#\w+');
    final mentionRegex = RegExp(r'@\w+');
    
    _hashtags = hashtagRegex.allMatches(text)
        .map((match) => match.group(0)!.substring(1))
        .toList();
    
    _mentions = mentionRegex.allMatches(text)
        .map((match) => match.group(0)!.substring(1))
        .toList();
  }

  void _saveDraft() {
    final draft = ReelDraft(
      id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
      videoPath: widget.videoPath,
      caption: _caption,
      hashtags: _hashtags,
      mentions: _mentions,
      location: _location,
      audio: _selectedAudio,
      effects: _appliedEffects,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );
    
    context.read<ReelsBloc>().add(SaveDraft(draft));
    Navigator.pop(context);
  }

  void _publishReel() {
    final draft = ReelDraft(
      id: 'draft_${DateTime.now().millisecondsSinceEpoch}',
      videoPath: widget.videoPath,
      caption: _caption,
      hashtags: _hashtags,
      mentions: _mentions,
      location: _location,
      audio: _selectedAudio,
      effects: _appliedEffects,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );
    
    context.read<ReelsBloc>().add(PublishReel(draft));
  }

  IconData _getEffectIcon(int index) {
    final icons = [
      Icons.blur_on,
      Icons.brightness_6,
      Icons.contrast,
      Icons.color_lens,
      Icons.auto_fix_high,
      Icons.filter_vintage,
      Icons.filter_b_and_w,
      Icons.filter_drama,
      Icons.filter_hdr,
      Icons.filter_tilt_shift,
      Icons.gradient,
      Icons.invert_colors,
    ];
    return icons[index % icons.length];
  }
}

class MusicLibrarySheet extends StatelessWidget {
  final Function(ReelAudio) onAudioSelected;

  const MusicLibrarySheet({super.key, required this.onAudioSelected});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Music Library',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: 20,
                itemBuilder: (context, index) {
                  final audio = ReelAudio(
                    id: 'audio_$index',
                    title: 'Song Title $index',
                    artist: 'Artist Name',
                    audioUrl: 'https://example.com/audio$index.mp3',
                    coverUrl: 'https://example.com/cover$index.jpg',
                    duration: 30,
                    isTrending: index < 5,
                  );
                  
                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[300],
                      ),
                      child: const Icon(Icons.music_note),
                    ),
                    title: Text(audio.title),
                    subtitle: Text(audio.artist),
                    trailing: audio.isTrending
                        ? const Icon(Icons.trending_up, color: Colors.red)
                        : null,
                    onTap: () {
                      onAudioSelected(audio);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}