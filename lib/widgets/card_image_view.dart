import 'package:flutter/widgets.dart';

import 'card_image_view_stub.dart'
    if (dart.library.js_interop) 'card_image_view_web.dart'
    as implementation;

Widget buildCardImageView(String imageUrl, double size) {
  return implementation.buildCardImageView(imageUrl, size);
}
