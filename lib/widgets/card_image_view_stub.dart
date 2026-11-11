import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

Widget buildCardImageView(String imageUrl, double size) {
  return Image.network(
    imageUrl,
    width: size,
    height: size,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.medium,
    webHtmlElementStrategy: WebHtmlElementStrategy.never,
    errorBuilder: (_, _, _) => const Icon(
      Icons.image_not_supported_outlined,
      size: 42,
      color: AppColors.textSecondary,
    ),
  );
}
