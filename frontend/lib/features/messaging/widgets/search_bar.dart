import 'package:flutter/material.dart';

class MessageSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final VoidCallback? onClear;

  const MessageSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  State<MessageSearchBar> createState() => _MessageSearchBarState();
}

class _MessageSearchBarState extends State<MessageSearchBar> {
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: (value) {
          setState(() => _isSearching = value.isNotEmpty);
          widget.onChanged?.call(value);
        },
        decoration: InputDecoration(
          hintText: 'Search messages',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    widget.controller.clear();
                    setState(() => _isSearching = false);
                    widget.onClear?.call();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}