import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileNotesWidget extends StatefulWidget {
  final String userId;

  const ProfileNotesWidget({super.key, required this.userId});

  @override
  State<ProfileNotesWidget> createState() => _ProfileNotesWidgetState();
}

class _ProfileNotesWidgetState extends State<ProfileNotesWidget> {
  final TextEditingController _noteController = TextEditingController();
  String _savedNote = '';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  void _loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    final note = prefs.getString('note_${widget.userId}') ?? '';
    setState(() {
      _savedNote = note;
      _noteController.text = note;
    });
  }

  void _saveNote() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('note_${widget.userId}', _noteController.text);
    setState(() {
      _savedNote = _noteController.text;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.note, size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Your note',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const Spacer(),
              if (!_isEditing && _savedNote.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: () => setState(() => _isEditing = true),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isEditing)
            Column(
              children: [
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    hintText: 'Add a note about this person...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 3,
                  maxLength: 200,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _noteController.text = _savedNote;
                        setState(() => _isEditing = false);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _saveNote,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            )
          else if (_savedNote.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _isEditing = true),
              child: Text(
                _savedNote,
                style: const TextStyle(fontSize: 14),
              ),
            )
          else
            GestureDetector(
              onTap: () => setState(() => _isEditing = true),
              child: const Text(
                'Tap to add a note about this person',
                style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}

class ReelsPlaybackSpeedMemory extends StatefulWidget {
  final Widget child;
  final Function(double) onSpeedChanged;

  const ReelsPlaybackSpeedMemory({super.key, required this.child, required this.onSpeedChanged});

  @override
  State<ReelsPlaybackSpeedMemory> createState() => _ReelsPlaybackSpeedMemoryState();
}

class _ReelsPlaybackSpeedMemoryState extends State<ReelsPlaybackSpeedMemory> {
  double _playbackSpeed = 1.0;
  bool _showSpeedControl = false;

  @override
  void initState() {
    super.initState();
    _loadPlaybackSpeed();
  }

  void _loadPlaybackSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    final speed = prefs.getDouble('reels_playback_speed') ?? 1.0;
    setState(() => _playbackSpeed = speed);
    widget.onSpeedChanged(speed);
  }

  void _savePlaybackSpeed(double speed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('reels_playback_speed', speed);
    setState(() => _playbackSpeed = speed);
    widget.onSpeedChanged(speed);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onDoubleTap: () => setState(() => _showSpeedControl = !_showSpeedControl),
          child: widget.child,
        ),
        if (_showSpeedControl)
          Positioned(
            top: 100,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Speed',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ...[0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) =>
                    GestureDetector(
                      onTap: () => _savePlaybackSpeed(speed),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: _playbackSpeed == speed ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${speed}x',
                          style: TextStyle(
                            color: _playbackSpeed == speed ? Colors.black : Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_playbackSpeed != 1.0)
          Positioned(
            bottom: 100,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_playbackSpeed}x',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}

class StorySharedFromTag extends StatelessWidget {
  final String originalPoster;
  final VoidCallback onTap;

  const StorySharedFromTag({super.key, required this.originalPoster, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      left: 16,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.share, color: Colors.white, size: 12),
              const SizedBox(width: 4),
              Text(
                'Shared from @$originalPoster',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}