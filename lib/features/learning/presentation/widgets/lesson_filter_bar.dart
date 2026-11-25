import 'package:flutter/material.dart';

import '../cubit/learning_cubit.dart';
import 'learning_widgets.dart';

class LessonSearchField extends StatelessWidget {
  const LessonSearchField({required this.onChanged, super.key});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search lessons',
          hintStyle: const TextStyle(color: muted),
          prefixIcon: const Icon(Icons.search_rounded, color: muted),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: BorderSide.none),
        ),
      );
}

class LessonFilterBar extends StatelessWidget {
  const LessonFilterBar({
    required this.filter,
    required this.sort,
    required this.onFilterChanged,
    required this.onSortChanged,
    super.key,
  });

  static const _filterLabels = {
    LessonFilter.all: 'All',
    LessonFilter.available: 'Available',
    LessonFilter.favorites: 'Favorites',
    LessonFilter.completed: 'Completed',
  };

  final LessonFilter filter;
  final LessonSort sort;
  final ValueChanged<LessonFilter> onFilterChanged;
  final ValueChanged<LessonSort> onSortChanged;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final entry in _filterLabels.entries)
                    AppFilterChip(
                      label: entry.value,
                      selected: filter == entry.key,
                      onSelected: () => onFilterChanged(entry.key),
                    ),
                ],
              ),
            ),
          ),
          PopupMenuButton<LessonSort>(
            tooltip: 'Sort lessons',
            initialValue: sort,
            onSelected: onSortChanged,
            icon: const Icon(Icons.swap_vert_rounded, color: ink),
            itemBuilder: (context) => const [
              PopupMenuItem(value: LessonSort.original, child: Text('Course order')),
              PopupMenuItem(value: LessonSort.title, child: Text('Title')),
              PopupMenuItem(value: LessonSort.duration, child: Text('Duration')),
            ],
          ),
        ],
      );
}

class AppFilterChip extends StatelessWidget {
  const AppFilterChip({required this.label, required this.selected, required this.onSelected, super.key});

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 7),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onSelected(),
          labelStyle: TextStyle(color: selected ? Colors.white : ink, fontWeight: FontWeight.w600, fontSize: 12),
          selectedColor: ink,
          checkmarkColor: Colors.white,
          backgroundColor: Colors.white,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          visualDensity: VisualDensity.compact,
        ),
      );
}
