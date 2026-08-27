import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../domain/recipe_share_codec.dart';

class ShareRecipesScreen extends StatelessWidget {
  const ShareRecipesScreen({super.key, required this.recipes});

  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final payload = RecipeShareCodec.encode(recipes);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shareRecipesTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.shareRecipesInstructions(recipes.length),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: payload,
                    version: QrVersions.auto,
                    size: 260,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Share.share(payload, subject: l10n.shareRecipesTitle),
                  icon: const Icon(Icons.ios_share),
                  label: Text(l10n.shareRecipesLinkButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
