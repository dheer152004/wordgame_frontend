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
      final image = web.HTMLImageElement()
        ..src = params! as String
        ..alt = ''
        ..draggable = false;
      image.style
        ..width = '100%'
        ..height = '100%'
        ..objectFit = 'contain';
      return image;
    });
    _viewFactoryRegistered = true;
  }

  return SizedBox(
    width: size,
    height: size,
    child: HtmlElementView(viewType: _viewType, creationParams: imageUrl),
  );
}
