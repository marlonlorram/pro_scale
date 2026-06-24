import 'package:flutter/widgets.dart';

import 'package:pro_scale/src/pro_scale_core.dart';

class ProScaleInit extends StatefulWidget {
  final Widget child;
  final double designWidth;
  final double designHeight;
  final DesignOrientation designOrientation;
  final double maxScaleFactor;

  const ProScaleInit({
    super.key,
    required this.child,
    required this.designWidth,
    required this.designHeight,
    this.designOrientation = DesignOrientation.portrait,
    this.maxScaleFactor = 1.5,
  });

  @override
  State<ProScaleInit> createState() => _ProScaleInitState();
}

class _ProScaleInitState extends State<ProScaleInit> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncScreenSize();
  }

  @override
  void didUpdateWidget(ProScaleInit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.designWidth != widget.designWidth ||
        oldWidget.designHeight != widget.designHeight ||
        oldWidget.designOrientation != widget.designOrientation ||
        oldWidget.maxScaleFactor != widget.maxScaleFactor) {
      _initialized = false;
      _syncScreenSize();
    }
  }

  void _syncScreenSize() {
    final Size size = MediaQuery.sizeOf(context);
    if (_initialized) {
      ProScaleCore().updateScreenSize(size);
    } else {
      ProScaleCore().init(
        designWidth: widget.designWidth,
        designHeight: widget.designHeight,
        screenSize: size,
        designOrientation: widget.designOrientation,
        maxScaleFactor: widget.maxScaleFactor,
      );
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
