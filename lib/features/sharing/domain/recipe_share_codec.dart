import 'dart:convert';
import 'dart:io';

import '../../recipes/domain/entities/recipe.dart';

/// Encodes/decodes a batch of recipes for offline sharing via QR code or
/// text link — JSON, gzip-compressed, base64url-encoded so the payload stays
/// as small as possible for QR density.
class RecipeShareCodec {
  const RecipeShareCodec._();

  static String encode(List<Recipe> recipes) {
    final json = jsonEncode({'recipes': recipes.map((r) => r.toJson()).toList()});
    final compressed = gzip.encode(utf8.encode(json));
    return base64Url.encode(compressed);
  }

  /// Throws a [FormatException] if [payload] isn't a valid encoded batch.
  static List<Recipe> decode(String payload) {
    final compressed = base64Url.decode(base64Url.normalize(payload));
    final json = utf8.decode(gzip.decode(compressed));
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    final recipes = decoded['recipes'] as List;
    return recipes.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
  }
}
