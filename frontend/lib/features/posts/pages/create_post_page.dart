import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/post_models.dart';
import '../editor/post_editor_page.dart';
import '../widgets/media_selector.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  List<XFile> _selectedMedia = [];
  PostLocation? _selectedLocation;
  List<UserTag> _taggedUsers = [];
  List<ProductTag> _taggedProducts = [];
  PostSettings _settings = const PostSettings();
  bool _isCarousel = false;
  String? _altText;
  DateTime? _scheduledDate;
  List<String> _collaborators = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        actions: [
          TextButton(
            onPressed: _selectedMedia.isNotEmpty ? _proceedToEditor : null,
            child: const Text('Next'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Media Selection
          if (_selectedMedia.isEmpty)
            Expanded(
              child: MediaSelector(
                onMediaSelected: (media) {
                  setState(() {
                    _selectedMedia = media;
                    _isCarousel = media.length > 1;
                  });
                },
                maxSelection: 10,
                allowVideo: true,
                maxVideoDuration: 60,
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  // Selected Media Preview
                  Container(
                    height: 300,
                    child: PageView.builder(
                      itemCount: _selectedMedia.length,
                      itemBuilder: (context, index) {
                        final media = _selectedMedia[index];
                        return Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              child: media.path.endsWith('.mp4')
                                  ? Container(
                                      color: Colors.black,
                                      child: const Center(
                                        child: Icon(Icons.play_circle_filled, 
                                                   color: Colors.white, size: 64),
                                      ),
                                    )
                                  : Image.file(File(media.path), fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                onPressed: () => _removeMedia(index),
                                icon: const Icon(Icons.close, color: Colors.white),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Media Controls
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _addMoreMedia,
                          icon: const Icon(Icons.add_photo_alternate),
                        ),
                        const SizedBox(width: 16),
                        if (_selectedMedia.length > 1)
                          Text('${_selectedMedia.length} items selected'),
                        const Spacer(),
                        TextButton(
                          onPressed: _proceedToEditor,
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                  ),

                  // Caption Input
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _captionController,
                            decoration: const InputDecoration(
                              hintText: 'Write a caption...',
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                            maxLength: 2200,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Post Options
                          _buildPostOption(
                            icon: Icons.location_on,
                            title: 'Add location',
                            subtitle: _selectedLocation?.name,
                            onTap: _selectLocation,
                          ),
                          
                          _buildPostOption(
                            icon: Icons.person_add,
                            title: 'Tag people',
                            subtitle: _taggedUsers.isNotEmpty 
                                ? '${_taggedUsers.length} people tagged'
                                : null,
                            onTap: _tagPeople,
                          ),
                          
                          _buildPostOption(
                            icon: Icons.shopping_bag,
                            title: 'Tag products',
                            subtitle: _taggedProducts.isNotEmpty 
                                ? '${_taggedProducts.length} products tagged'
                                : null,
                            onTap: _tagProducts,
                          ),
                          
                          _buildPostOption(
                            icon: Icons.accessibility,
                            title: 'Alt text',
                            subtitle: _altText,
                            onTap: _addAltText,
                          ),
                          
                          _buildPostOption(
                            icon: Icons.schedule,
                            title: 'Schedule post',
                            subtitle: _scheduledDate != null 
                                ? 'Scheduled for ${_formatDate(_scheduledDate!)}'
                                : null,
                            onTap: _schedulePost,
                          ),
                          
                          _buildPostOption(
                            icon: Icons.group,
                            title: 'Invite collaborator',
                            subtitle: _collaborators.isNotEmpty 
                                ? '${_collaborators.length} collaborators'
                                : null,
                            onTap: _addCollaborators,
                          ),
                          
                          _buildPostOption(
                            icon: Icons.settings,
                            title: 'Advanced settings',
                            onTap: _showAdvancedSettings,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Bottom Actions
          if (_selectedMedia.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _saveDraft,
                    child: const Text('Save Draft'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _publishPost,
                    child: Text(_scheduledDate != null ? 'Schedule' : 'Share'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
      if (_selectedMedia.isEmpty) {
        _isCarousel = false;
      }
    });
  }

  void _addMoreMedia() async {
    final List<XFile> newMedia = await _picker.pickMultipleMedia(
      limit: 10 - _selectedMedia.length,
    );
    
    setState(() {
      _selectedMedia.addAll(newMedia);
      _isCarousel = _selectedMedia.length > 1;
    });
  }

  void _proceedToEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostEditorPage(
          mediaFiles: _selectedMedia,
          isCarousel: _isCarousel,
          onEditComplete: (editedMedia) {
            // Handle edited media
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _selectLocation() {
    showModalBottomSheet(
      context: context,
      builder: (context) => LocationSelector(
        onLocationSelected: (location) {
          setState(() => _selectedLocation = location);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _tagPeople() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PeopleTagSelector(
        selectedMedia: _selectedMedia,
        onUsersTagged: (tags) {
          setState(() => _taggedUsers = tags);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _tagProducts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProductTagSelector(
        selectedMedia: _selectedMedia,
        onProductsTagged: (tags) {
          setState(() => _taggedProducts = tags);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _addAltText() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alt Text'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Describe this photo for people with visual impairments...',
          ),
          maxLines: 3,
          maxLength: 100,
          onChanged: (value) => _altText = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _schedulePost() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      
      if (time != null) {
        setState(() {
          _scheduledDate = DateTime(
            date.year, date.month, date.day,
            time.hour, time.minute,
          );
        });
      }
    }
  }

  void _addCollaborators() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CollaboratorSelector(
        onCollaboratorsSelected: (collaborators) {
          setState(() => _collaborators = collaborators);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showAdvancedSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => AdvancedSettingsSheet(
        settings: _settings,
        onSettingsChanged: (settings) {
          setState(() => _settings = settings);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _saveDraft() {
    // Save post as draft
    final draft = PostDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id',
      caption: _captionController.text,
      mediaPaths: _selectedMedia.map((m) => m.path).toList(),
      createdAt: DateTime.now(),
    );
    
    // TODO: Save draft to storage
    Navigator.pop(context);
  }

  void _publishPost() {
    // Create and publish post
    final post = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id',
      username: 'current_username',
      userAvatar: 'avatar_url',
      caption: _captionController.text,
      media: _selectedMedia.map((m) => PostMedia(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        url: m.path,
        type: m.path.endsWith('.mp4') ? MediaType.video : MediaType.photo,
        width: 1080,
        height: 1080,
      )).toList(),
      location: _selectedLocation,
      taggedUsers: _taggedUsers,
      taggedProducts: _taggedProducts,
      altText: _altText,
      settings: _settings,
      insights: const PostInsights(),
      createdAt: DateTime.now(),
      scheduledAt: _scheduledDate,
      status: _scheduledDate != null ? PostStatus.scheduled : PostStatus.published,
      collaborators: _collaborators,
    );
    
    // TODO: Publish post
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Placeholder widgets - these would be implemented separately
class LocationSelector extends StatelessWidget {
  final Function(PostLocation) onLocationSelected;

  const LocationSelector({Key? key, required this.onLocationSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Select Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text('Location $index'),
                  subtitle: Text('Address $index'),
                  onTap: () {
                    onLocationSelected(PostLocation(
                      id: 'loc_$index',
                      name: 'Location $index',
                      latitude: 0.0,
                      longitude: 0.0,
                    ));
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

class PeopleTagSelector extends StatelessWidget {
  final List<XFile> selectedMedia;
  final Function(List<UserTag>) onUsersTagged;

  const PeopleTagSelector({
    Key? key,
    required this.selectedMedia,
    required this.onUsersTagged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      padding: const EdgeInsets.all(16),
      child: const Column(
        children: [
          Text('Tag People', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(child: Center(child: Text('People tagging interface'))),
        ],
      ),
    );
  }
}

class ProductTagSelector extends StatelessWidget {
  final List<XFile> selectedMedia;
  final Function(List<ProductTag>) onProductsTagged;

  const ProductTagSelector({
    Key? key,
    required this.selectedMedia,
    required this.onProductsTagged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      padding: const EdgeInsets.all(16),
      child: const Column(
        children: [
          Text('Tag Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(child: Center(child: Text('Product tagging interface'))),
        ],
      ),
    );
  }
}

class CollaboratorSelector extends StatelessWidget {
  final Function(List<String>) onCollaboratorsSelected;

  const CollaboratorSelector({Key? key, required this.onCollaboratorsSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: const Column(
        children: [
          Text('Invite Collaborator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(child: Center(child: Text('Collaborator selection interface'))),
        ],
      ),
    );
  }
}

class AdvancedSettingsSheet extends StatefulWidget {
  final PostSettings settings;
  final Function(PostSettings) onSettingsChanged;

  const AdvancedSettingsSheet({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<AdvancedSettingsSheet> createState() => _AdvancedSettingsSheetState();
}

class _AdvancedSettingsSheetState extends State<AdvancedSettingsSheet> {
  late PostSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Advanced Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Hide like count'),
            subtitle: const Text('Only you will see the total number of likes'),
            value: _settings.hideLikeCount,
            onChanged: (value) {
              setState(() {
                _settings = PostSettings(
                  hideLikeCount: value,
                  turnOffComments: _settings.turnOffComments,
                  visibility: _settings.visibility,
                );
              });
            },
          ),
          
          SwitchListTile(
            title: const Text('Turn off commenting'),
            subtitle: const Text('You can change this later'),
            value: _settings.turnOffComments,
            onChanged: (value) {
              setState(() {
                _settings = PostSettings(
                  hideLikeCount: _settings.hideLikeCount,
                  turnOffComments: value,
                  visibility: _settings.visibility,
                );
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onSettingsChanged(_settings),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}