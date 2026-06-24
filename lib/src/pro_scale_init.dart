import 'package:flutter/widgets.dart';

import 'package:pro_scale/src/pro_scale_core.dart';
import 'package:pro_scale/src/pro_scale_scope.dart';

class ProScaleInit extends StatefulWidget {
  final Widget child;
  final double designWidth;
  final double designHeight;
  final DesignOrientation designOrientation;
  final double maxScaleFactor;
  final bool respectSystemTextScale;

  const ProScaleInit({
    super.key,
    required this.child,
    required this.designWidth,
    required this.designHeight,
    this.designOrientation = DesignOrientation.portrait,
    this.maxScaleFactor = 1.5,
    this.respectSystemTextScale = true,
  });

  @override
  State<ProScaleInit> createState() => _ProScaleInitState();
}

class _ProScaleInitState extends State<ProScaleInit> {
  bool _initialized = false;
  late Size _screenSize;
  late TextScaler _textScaler;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(ProScaleInit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.designWidth != widget.designWidth ||
        oldWidget.designHeight != widget.designHeight ||
        oldWidget.designOrientation != widget.designOrientation ||
        oldWidget.maxScaleFactor != widget.maxScaleFactor ||
        oldWidget.respectSystemTextScale != widget.respectSystemTextScale) {
      _initialized = false;
      _sync();
    }
  }

  void _sync() {
    _screenSize = MediaQuery.sizeOf(context);
    _textScaler = MediaQuery.textScalerOf(context);

    final ProScaleCore core = ProScaleCore();
    if (_initialized) {
      core.updateScreenSize(_screenSize);
    } else {
      core.init(
        designWidth: widget.designWidth,
        designHeight: widget.designHeight,
        screenSize: _screenSize,
        designOrientation: widget.designOrientation,
        maxScaleFactor: widget.maxScaleFactor,
        respectSystemTextScale: widget.respectSystemTextScale,
      );
      _initialized = true;
    }
    core.updateTextScaler(_textScaler);
  }

  @override
  Widget build(BuildContext context) {
    return ProScaleScope(
      screenSize: _screenSize,
      textScaler: _textScaler,
      child: widget.child,
    );
  }
}
