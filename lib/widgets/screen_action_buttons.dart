import 'package:flutter/material.dart';

class AppBackIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;

  const AppBackIconButton({
    required this.onPressed,
    this.tooltip = 'Back',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      tooltip: tooltip,
    );
  }
}

class AppRefreshIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String tooltip;
  final double iconSize;

  const AppRefreshIconButton({
    required this.onPressed,
    this.tooltip = 'Refresh',
    this.iconSize = 20,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.refresh_rounded),
      tooltip: tooltip,
      iconSize: iconSize,
      constraints: const BoxConstraints(),
      padding: EdgeInsets.zero,
    );
  }
}
