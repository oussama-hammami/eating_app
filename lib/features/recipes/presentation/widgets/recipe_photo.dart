import 'dart:io';

import 'package:flutter/material.dart';

/// Renders a recipe's photo from a bundled asset (path starting with
/// "assets/"), a remote URL (community recipes served from Supabase
/// Storage), or an on-device file (user-picked photos via image_picker, an
/// absolute filesystem path).
///
/// Falls back to a placeholder icon when [path] is null/empty, or when the
/// network/file image fails to load (broken URL, deleted file, offline).
class RecipePhoto extends StatelessWidget {
  const RecipePhoto({super.key, required this.path, this.width, this.height, this.fit});

  final String? path;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final path = this.path;
    if (path == null || path.isEmpty) {
      return _placeholder(context);
    }
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _placeholder(context),
      );
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _placeholder(context),
      );
    }
    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      color: colorScheme.secondaryContainer,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_menu,
        size: (width ?? height ?? 44) * 0.5,
        color: colorScheme.primary,
      ),
    );
  }
}
