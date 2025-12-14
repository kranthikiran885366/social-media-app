import 'package:flutter/material.dart';

class StoryStickerSelector extends StatefulWidget {
  final Function(Map<String, dynamic>) onStickerSelected;
  final Function(Map<String, dynamic>) onPollCreated;
  final Function(Map<String, dynamic>) onQuestionCreated;
  final Function(Map<String, dynamic>) onQuizCreated;
  final Function(Map<String, dynamic>) onEmojiSliderCreated;
  final Function(Map<String, dynamic>) onCountdownCreated;

  const StoryStickerSelector({
    Key? key,
    required this.onStickerSelected,
    required this.onPollCreated,
    required this.onQuestionCreated,
    required this.onQuizCreated,
    required this.onEmojiSliderCreated,
    required this.onCountdownCreated,
  }) : super(key: key);

  @override
  State<StoryStickerSelector> createState() => _StoryStickerSelectorState();
}

class _StoryStickerSelectorState extends State<StoryStickerSelector>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _pollQuestionController = TextEditingController();
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'GIFs'),
              Tab(text: 'Stickers'),
              Tab(text: 'Poll'),
              Tab(text: 'Question'),
              Tab(text: 'Quiz'),
              Tab(text: 'Slider'),
              Tab(text: 'Countdown'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGIFSelector(),
                _buildStickerSelector(),
                _buildPollCreator(),
                _buildQuestionCreator(),
                _buildQuizCreator(),
                _buildEmojiSliderCreator(),
                _buildCountdownCreator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGIFSelector() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            widget.onStickerSelected({'type': 'gif', 'url': 'gif_$index'});
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('GIF')),
          ),
        );
      },
    );
  }

  Widget _buildStickerSelector() {
    final stickers = ['❤️', '🔥', '😍', '🎉', '✨', '💯', '👑', '🌟'];
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stickers.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            widget.onStickerSelected({'type': 'emoji', 'emoji': stickers[index]});
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(stickers[index], style: const TextStyle(fontSize: 32))),
          ),
        );
      },
    );
  }

  Widget _buildPollCreator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _pollQuestionController,
            decoration: const InputDecoration(labelText: 'Ask a question...'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pollOptionControllers[0],
            decoration: const InputDecoration(labelText: 'Option 1'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pollOptionControllers[1],
            decoration: const InputDecoration(labelText: 'Option 2'),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              widget.onPollCreated({
                'question': _pollQuestionController.text,
                'options': _pollOptionControllers.map((c) => c.text).toList(),
              });
              Navigator.pop(context);
            },
            child: const Text('Add Poll'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCreator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const TextField(decoration: InputDecoration(labelText: 'Placeholder text...')),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              widget.onQuestionCreated({'placeholder': 'Ask me a question'});
              Navigator.pop(context);
            },
            child: const Text('Add Question'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCreator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const TextField(decoration: InputDecoration(labelText: 'Quiz question...')),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              widget.onQuizCreated({'question': 'Quiz question', 'options': ['A', 'B']});
              Navigator.pop(context);
            },
            child: const Text('Add Quiz'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiSliderCreator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const TextField(decoration: InputDecoration(labelText: 'Question (optional)')),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              widget.onEmojiSliderCreated({'emoji': '😍', 'question': 'Rate this!'});
              Navigator.pop(context);
            },
            child: const Text('Add Slider'),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownCreator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const TextField(decoration: InputDecoration(labelText: 'Event name')),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              widget.onCountdownCreated({'title': 'My Event', 'endDate': DateTime.now().toString()});
              Navigator.pop(context);
            },
            child: const Text('Add Countdown'),
          ),
        ],
      ),
    );
  }
}