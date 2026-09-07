import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../domain/recipe_share_codec.dart';
import 'import_recipes_screen.dart';

/// Scans a QR code produced by [ShareRecipesScreen], decodes it, then pushes
/// [ImportRecipesScreen]. Pops with the recipes the user chose to add, or
/// null if cancelled at any point.
class ScanRecipesScreen extends StatefulWidget {
  const ScanRecipesScreen({super.key});

  @override
  State<ScanRecipesScreen> createState() => _ScanRecipesScreenState();
}

class _ScanRecipesScreenState extends State<ScanRecipesScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showDecodeError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.scanDecodeError)),
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    if (capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;

    List<Recipe> recipes;
    try {
      recipes = RecipeShareCodec.decode(raw);
    } catch (_) {
      _showDecodeError();
      return;
    }
    if (recipes.isEmpty) return;

    _handled = true;
    final selected = await Navigator.of(context).push<List<Recipe>>(
      MaterialPageRoute(builder: (_) => ImportRecipesScreen(recipes: recipes)),
    );
    if (!mounted) return;
    if (selected == null) {
      _handled = false;
      return;
    }
    Navigator.of(context).pop(selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanRecipesTitle)),
      body: MobileScanner(controller: _controller, onDetect: _onDetect),
    );
  }
}
