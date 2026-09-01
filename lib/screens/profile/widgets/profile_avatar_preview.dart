import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../services/backend_api.dart';
import '../../../../theme/app_theme.dart';

class ProfileAvatarPreview extends StatelessWidget {
  final String avatarUrl;
  final double size;

  const ProfileAvatarPreview({
    super.key,
    required this.avatarUrl,
    this.size = 88,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppThemeColors.challengeCard(context),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppThemeColors.challengeCard(context).withAlpha(72),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: AppThemeColors.divider(context)),
        ),
        child: ClipOval(
          child: avatarUrl.isNotEmpty
              ? FutureBuilder<Uint8List>(
                  future: BackendApi.instance.fetchAvatarBytes(avatarUrl),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      return Image.memory(
                        snapshot.data!,
                        key: ValueKey(avatarUrl),
                        fit: BoxFit.cover,
                      );
                    }

                    return Image.network(
                      avatarUrl,
                      key: ValueKey('fallback-$avatarUrl'),
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        size: 40,
                        color: AppThemeColors.textOnPrimary(context),
                      ),
                    );
                  },
                )
              : Icon(
                  Icons.person,
                  size: 40,
                  color: AppThemeColors.textOnPrimary(context),
                ),
        ),
      ),
    );
  }
}
