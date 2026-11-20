import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

const String _viewType = 'nroq/flash-card-image';
bool _viewFactoryRegistered = false;

Widget buildCardImageView(String imageUrl, double size) {
  if (!_viewFactoryRegistered) {
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (
      int viewId, {
      Object? params,
    }) {
      final imageParams = params! as Map<Object?, Object?>;
      final image = web.HTMLImageElement()
        ..src = imageParams['url']! as String
        ..alt = ''
        ..draggable = false;
      final imageSize = '${imageParams['size']}px';
      image.style
        ..width = imageSize
        ..height = imageSize
        ..objectFit = 'contain'
        ..display = 'block';
      return image;
    });
    _viewFactoryRegistered = true;
  }

  return SizedBox(
    width: size,
    height: size,
    child: HtmlElementView(
      viewType: _viewType,
      creationParams: {'url': imageUrl, 'size': size},
    ),
  );
}
