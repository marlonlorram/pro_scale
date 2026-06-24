import 'package:pro_scale/src/pro_scale_core.dart';

extension ProScaleExtension on num {
  double get w => ProScaleCore().setWidth(toDouble());

  double get h => ProScaleCore().setHeight(toDouble());

  double get sp => ProScaleCore().setSp(toDouble());

  double get r => ProScaleCore().setRadius(toDouble());
}
