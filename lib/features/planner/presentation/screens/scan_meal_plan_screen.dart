import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/meal_plan_share_codec.dart';
import 'import_meal_plan_screen.dart';

/// Scans a QR code produced by [ShareMealPlanScreen], decodes it, then
/// pushes [ImportMealPlanScreen] for preview/confirmation. Pops with the
/// (entries, recipes) the user confirmed importing, or null if cancelled.
class ScanMealPlanScreen extends StatefulWidget {
  const ScanMealPlanScreen({super.key});

  @override
  State<ScanMealPlanScreen> createState() => _ScanMealPlanScreenState();
}

class _ScanMealPlanScreenState extends State<ScanMealPlanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    if (capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;

    DecodedMealPlan plan;
    try {
      plan = MealPlanShareCodec.decode(raw);
    } catch (_) {
      return;
    }
    if (plan.entries.isEmpty) return;

    _handled = true;
    final confirmed = await Navigator.of(context).push<DecodedMealPlan>(
      MaterialPageRoute(builder: (_) => ImportMealPlanScreen(plan: plan)),
    );
    if (!mounted) return;
    if (confirmed == null) {
      _handled = false;
      return;
    }
    Navigator.of(context).pop((confirmed.entries, confirmed.recipes));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.plannerScanTitle)),
      body: MobileScanner(controller: _controller, onDetect: _onDetect),
    );
  }
}
