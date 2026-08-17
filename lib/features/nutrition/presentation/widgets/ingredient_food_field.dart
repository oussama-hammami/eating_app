import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/units/ingredient_text_parser.dart';
import '../../../../core/units/unit.dart';
import '../../../meal_log/presentation/widgets/quantity_dialog.dart' show unitLabel;
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/food.dart';
import '../../domain/usecases/food_matcher.dart';
import '../providers/food_search_provider.dart';

/// The amount/unit/food resolved from an [IngredientFoodField]'s current
/// text, e.g. "1 tablespoon of olive oil" -> `(1, tbsp, <olive oil Food>)`.
/// [food] is null until a suggestion is picked (or after the text is edited
/// away from a previous pick).
typedef IngredientMatch = ({double? amount, Unit unit, Food? food});

/// A single free-text field ("1 tablespoon of olive oil") that parses out
/// an amount + unit, searches up to [maxSuggestions] CIQUAL food-name
/// suggestions for the remaining text in a floating overlay (200ms
/// debounced), and reports the resolved (amount, unit, food) via
/// [onMatchChanged] — for use in contexts (like the recipe ingredient list)
/// that aren't part of the Riverpod-driven Food Diary screen and so can't
/// share its single global search provider.
class IngredientFoodField extends ConsumerStatefulWidget {
  const IngredientFoodField({
    super.key,
    required this.controller,
    required this.label,
    this.onMatchChanged,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<IngredientMatch>? onMatchChanged;

  @override
  ConsumerState<IngredientFoodField> createState() => _IngredientFoodFieldState();
}

class _IngredientFoodFieldState extends ConsumerState<IngredientFoodField> {
  final _layerLink = LayerLink();
  final _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  Timer? _debounce;
  List<FoodMatch> _suggestions = const [];
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
    final parsed = parseIngredientText(widget.controller.text);
    widget.onMatchChanged?.call((amount: parsed.amount, unit: parsed.unit, food: null));
    final query = parsed.name.trim();
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
    final matcher = FoodMatcher(ref.read(foodRepositoryProvider));
    final result = await matcher.match(query);
    if (!mounted || requestId != _requestId) return;
    setState(() => _suggestions = result.candidates.take(maxSuggestions).toList());
    _showOverlay();
  }

  void _selectFood(Food food) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;
    final parsed = parseIngredientText(widget.controller.text);
    final amount = parsed.amount ?? 1;
    final amountText = formatIngredientAmount(amount);
    widget.controller.text =
        '$amountText ${unitLabel(l10n, parsed.unit)} ${food.displayName(languageCode)}';
    // The user explicitly tapped this suggestion, so it's confirmed
    // regardless of what FoodMatcher's confidence score said about it.
    widget.onMatchChanged?.call((amount: amount, unit: parsed.unit, food: food));
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
                  final match = _suggestions[index];
                  final confident = match.confidence >= FoodMatcher.autoAcceptThreshold;
                  return ListTile(
                    dense: true,
                    title: Text(match.food.displayName(languageCode)),
                    trailing: Icon(
                      confident ? Icons.check_circle : Icons.help_outline,
                      size: 18,
                      color: confident ? Colors.green : Colors.orange,
                    ),
                    onTap: () => _selectFood(match.food),
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
