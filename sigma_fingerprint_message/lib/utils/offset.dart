import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';

/// Calculate a safe random position for a widget inside a viewport.
///
/// Rules:
/// - left >= marginLeft
/// - top  >= marginTop
/// - widget never overflows right or bottom
/// - safe fallback if widget is larger than viewport
Offset calculateRandomPosition({
  required double viewportWidth,
  required double viewportHeight,
  required double widgetWidth,
  required double widgetHeight,
  double marginLeft = 24,
  double marginTop = 24,
  required Random random,
}) {
  debugPrint(
    '[OffsetCalc] Input: viewport=${viewportWidth}x$viewportHeight, widget=${widgetWidth}x$widgetHeight, margin: L=$marginLeft, T=$marginTop',
  );

  // -------- LEFT --------
  final double maxLeft = viewportWidth - widgetWidth;
  double left;

  if (maxLeft > marginLeft) {
    left = marginLeft + random.nextDouble() * (maxLeft - marginLeft);
  } else {
    left = marginLeft;
  }

  // -------- TOP --------
  final double maxTop = viewportHeight - widgetHeight;
  double top;

  if (maxTop > marginTop) {
    top = marginTop + random.nextDouble() * (maxTop - marginTop);
  } else {
    top = marginTop;
  }

  debugPrint(
    '[OffsetCalc] Result: maxLeft=$maxLeft, maxTop=$maxTop -> Offset($left, $top)',
  );

  return Offset(left, top);
}
