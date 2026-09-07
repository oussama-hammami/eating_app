import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../domain/entities/meal_plan_entry.dart';
import '../../domain/meal_plan_share_codec.dart';

/// Mirrors [ShareRecipesScreen] for a week of the meal planner: encodes the
/// entries (plus the recipes they reference) as a QR code / shareable text.
class ShareMealPlanScreen extends StatelessWidget {
  const ShareMealPlanScreen({super.key, required this.entries, required this.recipes});

  final List<MealPlanEntry> entries;
  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final payload = MealPlanShareCodec.encode(entries, recipes);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.plannerShareWeekTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.plannerShareWeekInstructions(entries.length),
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
                    errorStateBuilder: (context, error) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.qrPayloadTooLargeError,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(text: payload, subject: l10n.plannerShareWeekTitle),
                  ),
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
