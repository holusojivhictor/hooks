import 'dart:math';

import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  Rect? get rect {
    final box = findRenderObject() as RenderBox?;
    final rect = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    return rect;
  }

  static double _screenWidth = 0;
  static double _storyTileHeight = 0;
  static int _storyTileMaxLines = 4;
  static const double _screenWidthLowerBound = 430;
  static const double _screenWidthUpperBound = 850;
  static const double _picHeightLowerBound = 110;
  static const double _picHeightUpperBound = 128;
  static const double _smallPicHeight = 100;
  static const double _picHeightFactor = 0.3;

  double get storyTileHeight {
    final double screenWidth = min(MediaQuery.of(this).size.height, MediaQuery.of(this).size.width);

    if (screenWidth == _screenWidth) {
      return _storyTileHeight;
    } else {
      _screenWidth = screenWidth;
    }

    final showSmallerPreviewPic = screenWidth > _screenWidthLowerBound &&
        screenWidth < _screenWidthUpperBound;
    final height = showSmallerPreviewPic
        ? _smallPicHeight
        : (screenWidth * _picHeightFactor)
            .clamp(_picHeightLowerBound, _picHeightUpperBound);
    final maxLines = height == _smallPicHeight ? 3 : 4;
    _storyTileMaxLines = maxLines;

    _storyTileHeight = height;
    return height;
  }

  int get storyTileMaxLines {
    return _storyTileMaxLines;
  }
}
