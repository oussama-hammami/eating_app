import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/food.dart';
import '../providers/food_search_provider.dart';

/// A plain text field that shows up to [maxSuggestions] CIQUAL food-name
/// suggestions in a floating overlay as the user types (200ms debounced),
/// for use in contexts (like the recipe ingredient list) that aren't part
/// of the Riverpod-driven Food Diary screen and so can't share its single
/// global search provider.
class IngredientFoodField extends ConsumerStatefulWidget {
  const IngredientFoodField({
    super.key,
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  ConsumerState<IngredientFoodField> createState() => _IngredientFoodFieldState();
}

class _IngredientFoodFieldState extends ConsumerState<IngredientFoodField> {
  final _layerLink = LayerLink();
  final _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  Timer? _debounce;
  List<Food> _suggestions = const [];
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // Delay so a tap on a suggestion (which briefly steals focus) has a
      // chance to register before the overlay is torn down.
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!_focusNode.hasFocus) _removeOverlay();
      });
    }
  }

  void _onTextChanged() {
    _debounce?.cancel();
    final query = widget.controller.text.trim();
    if (query.isEmpty) {
      _requestId++;
      setState(() => _suggestions = const []);
      _removeOverlay();
      return;
    }
    _debounce = Timer(searchDebounce, () => _search(query));
  }

  Future<void> _search(String query) async {
    final requestId = ++_requestId;
    final results = await ref.read(foodRepositoryProvider).search(query, limit: maxSuggestions);
    if (!mounted || requestId != _requestId) return;
    setState(() => _suggestions = results);
    _showOverlay();
  }

  void _selectFood(Food food) {
    final languageCode = Localizations.localeOf(context).languageCode;
    widget.controller.text = food.displayName(languageCode);
    _requestId++;
    setState(() => _suggestions = const []);
    _removeOverlay();
    _focusNode.unfocus();
  }

  void _showOverlay() {
    _removeOverlay();
    if (_suggestions.isEmpty || !_focusNode.hasFocus) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    final width = renderBox?.size.width ?? 240.0;
    final languageCode = Localizations.localeOf(context).languageCode;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, (renderBox?.size.height ?? 56) + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final food = _suggestions[index];
                  return ListTile(
                    dense: true,
                    title: Text(food.displayName(languageCode)),
                    onTap: () => _selectFood(food),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(labelText: widget.label),
      ),
    );
  }
}
