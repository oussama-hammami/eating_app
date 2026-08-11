import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/food_search_provider.dart';

class FoodSearchField extends ConsumerWidget {
  const FoodSearchField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      controller: controller,
      onChanged: (value) =>
          ref.read(foodSearchProvider.notifier).onQueryChanged(value),
      decoration: InputDecoration(
        hintText: 'Search foods…',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  ref.read(foodSearchProvider.notifier).clear();
                },
              ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
