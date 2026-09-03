import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Semantic colors that sit outside Material's [ColorScheme] (which only
/// carries `error`). Success/warning/info are deliberately muted rather than
/// the typical bright nutrition-app red/yellow/green, and are meant for
/// status meaning only — never for decoration.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;

  static const light = AppSemanticColors(
    success: AppPalette.successLight,
    onSuccess: Colors.white,
    warning: AppPalette.warningLight,
    onWarning: AppPalette.charcoal,
    info: AppPalette.infoLight,
    onInfo: Colors.white,
  );

  static const dark = AppSemanticColors(
    success: AppPalette.successDark,
    onSuccess: AppPalette.darkBackground,
    warning: AppPalette.warningDark,
    onWarning: AppPalette.darkBackground,
    info: AppPalette.infoDark,
    onInfo: AppPalette.darkBackground,
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
    );
  }
}

/// Convenience accessor: `context.semanticColors.success`.
extension AppSemanticColorsX on BuildContext {
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;
}
