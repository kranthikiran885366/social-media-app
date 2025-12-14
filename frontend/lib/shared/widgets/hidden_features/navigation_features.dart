import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinnableTabNavigation extends StatefulWidget {
  final List<NavigationTab> tabs;
  final Function(int) onTabChanged;

  const PinnableTabNavigation({super.key, required this.tabs, required this.onTabChanged});

  @override
  State<PinnableTabNavigation> createState() => _PinnableTabNavigationState();
}

class _PinnableTabNavigationState extends State<PinnableTabNavigation> {
  List<NavigationTab> _orderedTabs = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTabOrder();
  }

  void _loadTabOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOrder = prefs.getStringList('tab_order');
    
    if (savedOrder != null) {
      _orderedTabs = savedOrder.map((id) => 
        widget.tabs.firstWhere((tab) => tab.id == id, orElse: () => widget.tabs.first)
      ).toList();
    } else {
      _orderedTabs = List.from(widget.tabs);
    }
    setState(() {});
  }

  void _saveTabOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tab_order', _orderedTabs.map((tab) => tab.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: _orderedTabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedIndex = index);
                widget.onTabChanged(index);
              },
              onLongPress: () => _showTabOptions(tab, index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab.icon,
                      color: _selectedIndex == index ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: _selectedIndex == index ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showTabOptions(NavigationTab tab, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.push_pin),
            title: const Text('Pin to front'),
            onTap: () {
              _moveTabToFront(index);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Reorder tabs'),
            onTap: () {
              Navigator.pop(context);
              _showReorderDialog();
            },
          ),
        ],
      ),
    );
  }

  void _moveTabToFront(int index) {
    final tab = _orderedTabs.removeAt(index);
    _orderedTabs.insert(0, tab);
    _saveTabOrder();
    setState(() => _selectedIndex = 0);
  }

  void _showReorderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reorder Tabs'),
        content: SizedBox(
          width: double.maxFinite,
          child: ReorderableListView(
            shrinkWrap: true,
            children: _orderedTabs.map((tab) => 
              ListTile(
                key: ValueKey(tab.id),
                leading: Icon(tab.icon),
                title: Text(tab.label),
              ),
            ).toList(),
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              final tab = _orderedTabs.removeAt(oldIndex);
              _orderedTabs.insert(newIndex, tab);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _saveTabOrder();
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class SuggestedShortcutsWidget extends StatefulWidget {
  final List<ShortcutAction> shortcuts;

  const SuggestedShortcutsWidget({super.key, required this.shortcuts});

  @override
  State<SuggestedShortcutsWidget> createState() => _SuggestedShortcutsWidgetState();
}

class _SuggestedShortcutsWidgetState extends State<SuggestedShortcutsWidget> {
  List<ShortcutAction> _suggestedShortcuts = [];

  @override
  void initState() {
    super.initState();
    _generateSuggestions();
  }

  void _generateSuggestions() {
    // Mock AI-based suggestions based on usage patterns
    _suggestedShortcuts = widget.shortcuts.where((shortcut) => 
      shortcut.usageCount > 5
    ).take(3).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_suggestedShortcuts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggested Shortcuts',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _suggestedShortcuts.map((shortcut) => 
              ActionChip(
                avatar: Icon(shortcut.icon, size: 16),
                label: Text(shortcut.label),
                onPressed: shortcut.action,
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }
}

class FollowingCategoriesWidget extends StatefulWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;

  const FollowingCategoriesWidget({
    super.key, 
    required this.categories, 
    required this.onCategorySelected
  });

  @override
  State<FollowingCategoriesWidget> createState() => _FollowingCategoriesWidgetState();
}

class _FollowingCategoriesWidgetState extends State<FollowingCategoriesWidget> {
  String _selectedCategory = 'All';
  String _sortBy = 'Recent';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.categories.length,
                  itemBuilder: (context, index) {
                    final category = widget.categories[index];
                    final isSelected = category == _selectedCategory;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = category);
                        widget.onCategorySelected(category);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) => setState(() => _sortBy = value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'Recent', child: Text('Recent')),
                  const PopupMenuItem(value: 'Alphabetical', child: Text('A-Z')),
                  const PopupMenuItem(value: 'Most Active', child: Text('Most Active')),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('Sorted by: $_sortBy', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Spacer(),
              Text('${widget.categories.length} categories', 
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}

class NavigationTab {
  final String id;
  final String label;
  final IconData icon;

  NavigationTab({required this.id, required this.label, required this.icon});
}

class ShortcutAction {
  final String label;
  final IconData icon;
  final VoidCallback action;
  final int usageCount;

  ShortcutAction({
    required this.label, 
    required this.icon, 
    required this.action, 
    this.usageCount = 0
  });
}