import 'package:flutter/material.dart';

class ShopCategories extends StatelessWidget {
  final TabController tabController;
  final List<String> categories;
  final Function(String) onCategoryChanged;

  const ShopCategories({
    super.key,
    required this.tabController,
    required this.categories,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        onTap: (index) => onCategoryChanged(categories[index]),
        tabs: categories.map((category) => Tab(text: category)).toList(),
      ),
    );
  }
}