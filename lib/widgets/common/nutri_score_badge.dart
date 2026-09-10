import 'package:flutter/material.dart';

/// Nutri-Score grade, A (best) through E (worst).
enum NutriScoreGrade { a, b, c, d, e }

/// Santé Publique France compliant Nutri-Score pill badge.
///
/// Colors are the official Nutri-Score scale and are intentionally not
/// themed off [ColorScheme] — the scale's meaning depends on using its
/// standard, recognizable colors.
class NutriScoreBadge extends StatelessWidget {
  const NutriScoreBadge({super.key, required this.grade, this.compact = false});

  final NutriScoreGrade grade;
  final bool compact;

  static const _colors = {
    NutriScoreGrade.a: Color(0xFF038141),
    NutriScoreGrade.b: Color(0xFF85BB2F),
    NutriScoreGrade.c: Color(0xFFFECB02),
    NutriScoreGrade.d: Color(0xFFEE8100),
    NutriScoreGrade.e: Color(0xFFE63E11),
  };

  static const _labels = {
    NutriScoreGrade.a: 'A',
    NutriScoreGrade.b: 'B',
    NutriScoreGrade.c: 'C',
    NutriScoreGrade.d: 'D',
    NutriScoreGrade.e: 'E',
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[grade]!;
    final onColor = grade == NutriScoreGrade.c ? Colors.black87 : Colors.white;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        compact ? _labels[grade]! : 'Nutri-Score ${_labels[grade]!}',
        style: TextStyle(
          color: onColor,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 12 : 13,
        ),
      ),
    );
  }
}
