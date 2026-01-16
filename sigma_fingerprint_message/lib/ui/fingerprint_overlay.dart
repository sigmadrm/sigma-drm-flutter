import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/fingerprint_settings.dart';
import '../utils/color.dart';
import '../utils/offset.dart';

class FingerprintOverlay extends StatefulWidget {
  final FingerprintSettings settings;
  final String deviceId;

  const FingerprintOverlay({
    super.key,
    required this.settings,
    required this.deviceId,
  });

  @override
  State<FingerprintOverlay> createState() => _FingerprintOverlayState();
}

class _FingerprintOverlayState extends State<FingerprintOverlay> {
  Timer? _cycleTimer;
  final Random _random = Random();

  double _left = 0;
  double _top = 0;
  bool _isVisible = true;
  bool _needsRandomize = false;
  int _pointIndex = 0;

  @override
  void initState() {
    super.initState();
    _startDisplayCycle();
  }

  @override
  void didUpdateWidget(covariant FingerprintOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.settings.equals(oldWidget.settings)) {
      _stopDisplayCycle();
      _startDisplayCycle();
    }
  }

  @override
  void dispose() {
    _stopDisplayCycle();
    super.dispose();
  }

  void _stopDisplayCycle() {
    _cycleTimer?.cancel();
    _cycleTimer = null;
  }

  void _startDisplayCycle() {
    final isForensic = widget.settings.outputType == FPOutputType.FORENSIC;

    if (isForensic) {
      _runForensicCycle();
    } else {
      if (widget.settings.displayAt == FPDisplayAtType.AT_AUTO) {
        _runOvertAutoCycle();
      } else {
        setState(() {
          _isVisible = true;
          _left = widget.settings.settings.px.toDouble();
          _top = widget.settings.settings.py.toDouble();
          _needsRandomize = false;
        });
      }
    }
  }

  // ---------- CYCLES ----------

  void _runForensicCycle() {
    _pointIndex = 0;
    _scheduleForensicStep();
  }

  void _scheduleForensicStep() {
    _cycleTimer?.cancel();

    if (_pointIndex < 3) {
      setState(() {
        _isVisible = true;
        _needsRandomize = true;
      });
      _pointIndex++;
      _cycleTimer = Timer(
        const Duration(milliseconds: 30),
        _scheduleForensicStep,
      );
    } else {
      setState(() => _isVisible = false);
      _pointIndex = 0;
      _cycleTimer = Timer(const Duration(seconds: 3), _scheduleForensicStep);
    }
  }

  void _runOvertAutoCycle() {
    _cycleTimer?.cancel();
    setState(() {
      _isVisible = true;
      _needsRandomize = true;
    });
    _cycleTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() => _needsRandomize = true);
    });
  }

  // ---------- BUILD ----------

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final settings = widget.settings;
    final style = settings.settings;

    // ---------- TEXT PREP ----------

    final baseStyle = TextStyle(
      color: parseColor(style.textColor),
      fontSize: style.fontSize.toDouble(),
      fontWeight: FontWeight.w600,
      height: 1.2,
      decoration: TextDecoration.none,
      inherit: false, // Ensure no inherited styles (like font family)
    );

    final List<_FPLine> lines = [];

    if (settings.message.isNotEmpty) {
      lines.add(_FPLine(settings.message, baseStyle));
    }

    final showDeviceId =
        settings.outputType == FPOutputType.FORENSIC ||
        (settings.outputType == FPOutputType.OVERT && settings.displayMAC);

    if (showDeviceId) {
      lines.add(
        _FPLine(
          widget.deviceId,
          baseStyle.copyWith(fontWeight: FontWeight.w400),
        ),
      );
    }

    final decoration = BoxDecoration(
      color: style.displayBackground
          ? parseColor(style.bgColor)
          : Colors.transparent,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final double marginLeft;
        final double marginTop;
        final screenWidth = mediaQuery.size.width;
        final textScaler = mediaQuery.textScaler;

        if (screenWidth < 600) {
          // Mobile
          marginLeft = 12;
          marginTop = 24; // status bar height
        } else if (screenWidth < 1024) {
          // Tablet
          marginLeft = 24;
          marginTop = 24; // status bar height
        } else {
          // Desktop/TV
          marginLeft = 48;
          marginTop = 24;
        }

        // ---------- MEASURE REAL SIZE ----------

        const double lineSpacing = 2;
        const double hPad = 8;
        const double vPad = 4;

        double maxLineWidth = 0;
        double totalHeight = 0;

        for (int i = 0; i < lines.length; i++) {
          final tp = TextPainter(
            text: TextSpan(text: lines[i].text, style: lines[i].style),
            textDirection: TextDirection.ltr,
            textScaler: textScaler, // Sync with Text widget scaling
            maxLines: 1,
          )..layout();

          maxLineWidth = max(maxLineWidth, tp.width);
          totalHeight += tp.height;
          if (i < lines.length - 1) {
            totalHeight += lineSpacing;
          }
        }

        final double realWidth = maxLineWidth + 2 * hPad;
        final double realHeight = totalHeight + 2 * vPad;

        // ---------- SAFE RANDOM (USING UTILS) ----------

        if (_needsRandomize) {
          final offset = calculateRandomPosition(
            viewportWidth: constraints.maxWidth,
            viewportHeight: constraints.maxHeight,
            widgetWidth: realWidth,
            widgetHeight: realHeight,
            marginLeft: marginLeft,
            marginTop: marginTop,
            random: _random,
          );

          _left = offset.dx;
          _top = offset.dy;

          _needsRandomize = false;
        }

        // ---------- FINAL CLAMP (ANTI-OVERFLOW) ----------

        final double left = _left.clamp(
          marginLeft,
          max(marginLeft, constraints.maxWidth - realWidth),
        );

        final double top = _top.clamp(
          marginTop,
          max(marginTop, constraints.maxHeight - realHeight),
        );

        // ---------- RENDER ----------

        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              child: Opacity(
                opacity: settings.opacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(lines.length, (i) {
                    final isLast = i == lines.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: isLast ? 0 : lineSpacing,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: hPad,
                          vertical: vPad,
                        ),
                        decoration: decoration,
                        child: Text(lines[i].text, style: lines[i].style),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FPLine {
  final String text;
  final TextStyle style;
  const _FPLine(this.text, this.style);
}
