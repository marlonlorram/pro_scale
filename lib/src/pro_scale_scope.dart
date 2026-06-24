import 'package:flutter/widgets.dart';

import 'package:pro_scale/src/pro_scale_core.dart';

class ProScaleScope extends InheritedWidget {
  const ProScaleScope({
    super.key,
    required this.screenSize,
    required this.textScaler,
    required super.child,
  });

  final Size screenSize;
  final TextScaler textScaler;

  @override
  bool updateShouldNotify(ProScaleScope oldWidget) =>
      screenSize != oldWidget.screenSize || textScaler != oldWidget.textScaler;
}

final class ProScale {
  const ProScale._();

  static ProScaleCore of(BuildContext context) {
    final ProScaleScope? scope = context
        .dependOnInheritedWidgetOfExactType<ProScaleScope>();
    assert(
      scope != null,
      'ProScale.of() was called without a ProScaleInit ancestor.',
    );
    return ProScaleCore();
  }
}

extension BuildContextProScale on BuildContext {
  ProScaleCore get scale => ProScale.of(this);
}
