import 'package:flutter/material.dart';
import '../models/creator_models.dart';

class ContentScheduler extends StatefulWidget {
  const ContentScheduler({super.key});

  @override
  State<ContentScheduler> createState() => _ContentSchedulerState();
}

class _ContentSchedulerState extends State<ContentScheduler> {
  final List<ContentDraft> _drafts = [];
  final List<ContentDraft> _scheduled = [];

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Content Manager'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Drafts'),
              Tab(text: 'Scheduled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDraftsTab(),
            _buildScheduledTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _createNewDraft,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildDraftsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _drafts.length,
      itemBuilder: (context, index) {
        final draft = _drafts[index];
        return _buildDraftCard(draft);
      },
    );
  }

  Widget _buildScheduledTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _scheduled.length,
      itemBuilder: (context, index) {
        final content = _scheduled[index];
        return _buildScheduledCard(content);
      },
    );
  }

  Widget _buildDraftCard(ContentDraft draft) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getContentTypeIcon(draft.type),
                const SizedBox(width: 8),
                Text(
                  draft.type.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(draft.updatedAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              draft.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
            if (draft.mediaUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: draft.mediaUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _editDraft(draft),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => _scheduleDraft(draft),
                  icon: const Icon(Icons.schedule, size: 16),
                  label: const Text('Schedule'),
                ),
                TextButton.icon(
                  onPressed: () => _deleteDraft(draft),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledCard(ContentDraft content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getContentTypeIcon(content.type),
                const SizedBox(width: 8),
                Text(
                  content.type.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'SCHEDULED',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Posts on ${_formatDateTime(content.scheduledTime!)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _editScheduled(content),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => _cancelScheduled(content),
                  icon: const Icon(Icons.cancel, size: 16),
                  label: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getContentTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'post':
        return const Icon(Icons.grid_on, size: 16, color: Colors.blue);
      case 'reel':
        return const Icon(Icons.video_library, size: 16, color: Colors.purple);
      case 'story':
        return const Icon(Icons.auto_stories, size: 16, color: Colors.green);
      default:
        return const Icon(Icons.article, size: 16, color: Colors.grey);
    }
  }

  void _loadContent() {
    setState(() {
      _drafts.addAll([
        ContentDraft(
          id: '1',
          type: 'post',
          content: 'Check out this amazing sunset! #photography #nature',
          mediaUrls: ['image1.jpg'],
          metadata: {},
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        ContentDraft(
          id: '2',
          type: 'reel',
          content: 'Quick cooking tip for busy weekdays! #cooking #tips',
          mediaUrls: ['video1.mp4'],
          metadata: {},
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ]);

      _scheduled.addAll([
        ContentDraft(
          id: '3',
          type: 'post',
          content: 'Monday motivation! Ready to start the week strong 💪',
          mediaUrls: ['image2.jpg'],
          scheduledTime: DateTime.now().add(const Duration(days: 1)),
          metadata: {},
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
      ]);
    });
  }

  void _createNewDraft() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Draft'),
        content: const Text('Choose content type:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addDraft('post');
            },
            child: const Text('Post'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addDraft('reel');
            },
            child: const Text('Reel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addDraft('story');
            },
            child: const Text('Story'),
          ),
        ],
      ),
    );
  }

  void _addDraft(String type) {
    final draft = ContentDraft(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      content: 'New $type draft...',
      mediaUrls: [],
      metadata: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    setState(() => _drafts.add(draft));
  }

  void _editDraft(ContentDraft draft) {}
  void _scheduleDraft(ContentDraft draft) {}
  void _deleteDraft(ContentDraft draft) {
    setState(() => _drafts.remove(draft));
  }
  void _editScheduled(ContentDraft content) {}
  void _cancelScheduled(ContentDraft content) {
    setState(() => _scheduled.remove(content));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}