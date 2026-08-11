/// Accent-folding / case-folding used for search matching.
///
/// Mirrors tools/ciqual_import/text_normalizer.py exactly so a query typed
/// on-device normalizes to the same string that was indexed at import time.
class TextNormalizer {
  const TextNormalizer._();

  static const Map<String, String> _accentMap = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'å': 'a',
    'ç': 'c',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'î': 'i', 'ï': 'i', 'í': 'i',
    'ñ': 'n',
    'ò': 'o', 'ô': 'o', 'ö': 'o', 'ó': 'o', 'õ': 'o',
    'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
    'ý': 'y', 'ÿ': 'y',
    'œ': 'oe', 'æ': 'ae',
  };

  /// Lowercase + strip accents so search is case- and accent-insensitive.
  static String normalize(String text) {
    final lowered = text.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lowered.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_accentMap[char] ?? char);
    }
    return buffer.toString();
  }
}
