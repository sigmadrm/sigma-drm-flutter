import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../models/message_settings.dart';
import '../utils/color.dart';

class MessageOverlay extends StatelessWidget {
  final MessageSettings settings;
  final String deviceId;

  const MessageOverlay({
    super.key,
    required this.settings,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    bool useRtlText = false;

    String rawMessage = settings.outputType == MessageOutputType.FORCE_FP
        ? "[$deviceId] ${settings.body}"
        : settings.body;
    // Calculate text height based on fontSize and lineHeight
    final double lineHeight = 1.5;
    final double fontSize = settings.fontSize.toDouble();
    final double textHeight = settings.fontSize.toDouble() * lineHeight;
    final textStyle = TextStyle(
      color: parseColor(settings.textColor),
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      height: lineHeight,
      decoration: TextDecoration.none,
      background: Paint()..color = Colors.transparent,
      inherit: true,
    );

    debugPrint(
      "Message Overlay: $rawMessage, text color: ${settings.textColor}, bg color: ${settings.bgColor}, font size: ${settings.fontSize}, output type: ${settings.outputType}",
    );

    // Responsive padding based on device type
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final EdgeInsets responsivePadding;
    if (screenWidth < 600) {
      // Mobile: reduce by 4x
      responsivePadding = const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      );
    } else if (screenWidth < 1024) {
      // Tablet: reduce by 2x
      responsivePadding = const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      );
    } else {
      // Desktop/TV: original padding
      responsivePadding = const EdgeInsets.symmetric(
        horizontal: 48,
        vertical: 24,
      );
    }

    // Inner container padding - reduce by 8 when < 1024
    final double innerHorizontalPadding = screenWidth < 1024 ? 16 : 24;
    final double innerVerticalPadding = screenWidth < 1024 ? 8 : 16;
    final double borderRadius = screenWidth < 1024 ? 8 : 16;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: responsivePadding,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            height:
                textHeight +
                (innerVerticalPadding * 2), // text height + vertical padding
            padding: EdgeInsets.symmetric(
              horizontal: innerHorizontalPadding,
              vertical: innerVerticalPadding,
            ),
            decoration: BoxDecoration(
              color: parseColor(settings.bgColor).withValues(alpha: 1),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final displayText = _padTextWithSpaces(
                  text: rawMessage,
                  style: textStyle,
                  maxWidth: constraints.maxWidth,
                  isRtl: useRtlText,
                  textScaler: mediaQuery.textScaler,
                );

                return Marquee(
                  text: displayText,
                  style: textStyle,
                  startPadding: 0,
                  blankSpace: 100,
                  velocity: 100,
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  showFadingOnlyWhenScrolling: true,
                  startAfter: const Duration(seconds: 1),
                  pauseAfterRound: Duration.zero,
                  textDirection: useRtlText
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  numberOfRounds: null, // loop
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _padTextWithSpaces({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required bool isRtl,
    required TextScaler textScaler,
  }) {
    String spaces = "";

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      textScaler: textScaler,
    )..layout();

    final double textWidth = textPainter.width;
    debugPrint("Text width: $textWidth, maxWidth: $maxWidth, isRtl: $isRtl");

    // Use do-while so we can break early but still return once at the end
    do {
      // Text already fills or exceeds the container
      if (textWidth > maxWidth) {
        break;
      }

      // Measure width of a single space
      final spacePainter = TextPainter(
        text: TextSpan(text: ' ', style: style),
        maxLines: 1,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        textScaler: textScaler,
      )..layout();

      final double spaceWidth = spacePainter.width;
      if (spaceWidth == 0) {
        break;
      }

      final int spaceCount = ((maxWidth - textWidth) / spaceWidth).ceil();

      spaces = ' ' * spaceCount;
      debugPrint("spaceWidth: $spaceWidth, spaceCount: $spaceCount, ");
    } while (false);

    String result = isRtl ? spaces + text : text + spaces;
    debugPrint(
      "PadTextWithSpaces Result = $result, text = $text, spaces = ${spaces.length}",
    );
    return result;
  }
}
