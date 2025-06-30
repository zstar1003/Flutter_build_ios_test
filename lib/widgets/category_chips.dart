import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class CategoryChips extends StatefulWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.categories.map((category) {
        final isSelected = selectedCategory == category;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCategory = isSelected ? null : category;
            });
            if (!isSelected) {
              widget.onCategorySelected(category);
              HapticFeedback.lightImpact();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected 
                ? AppTheme.primaryGradient
                : null,
              color: isSelected 
                ? null
                : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(25),
              border: isSelected 
                ? null
                : Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
              boxShadow: isSelected 
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(category),
                  size: 18,
                  color: isSelected 
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
                ),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: TextStyle(
                    color: isSelected 
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '励志':
        return Icons.trending_up;
      case '人生':
        return Icons.psychology;
      case '成功':
        return Icons.emoji_events;
      case '智慧':
        return Icons.lightbulb_outline;
      case '爱情':
        return Icons.favorite_outline;
      case '友谊':
        return Icons.people_outline;
      case '教育':
        return Icons.school_outlined;
      case '科学':
        return Icons.science_outlined;
      case '艺术':
        return Icons.palette_outlined;
      case '哲学':
        return Icons.auto_stories;
      default:
        return Icons.category;
    }
  }
} 