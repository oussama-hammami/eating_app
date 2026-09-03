import 'dart:io';

import 'package:flutter/material.dart';

/// Renders a recipe's photo from a bundled asset (path starting with
/// "assets/"), a remote URL (community recipes served from Supabase
/// Storage), or an on-device file (user-picked photos via image_picker, an
/// absolute filesystem path).
class RecipePhoto extends StatelessWidget {
  const RecipePhoto({super.key, required this.path, this.width, this.height, this.fit});

  final String path;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, width: width, height: height, fit: fit);
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, width: width, height: height, fit: fit);
    }
    return Image.file(File(path), width: width, height: height, fit: fit);
  }
}
