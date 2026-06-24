import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_scale/pro_scale.dart';

void main() {
  setUp(() => ProScaleCore().reset());

  test('a zero / unmeasured screen size scales to 1.0, not 0', () {
    ProScaleCore().init(
      designWidth: 375,
      designHeight: 812,
      screenSize: Size.zero,
    );
    expect(ProScaleCore().scaleWidth, 1.0);
    expect(ProScaleCore().scaleHeight, 1.0);
    expect(ProScaleCore().setWidth(220), 220);
  });

  Widget wrap(Size size, Widget child) => MediaQuery(
    data: MediaQueryData(size: size),
    child: ProScaleInit(designWidth: 400, designHeight: 400, child: child),
  );

  testWidgets('a screen that subscribes reflows its static .w on resize', (
    tester,
  ) async {
    final widths = <double>[];
    final probe = Builder(
      builder: (context) {
        final scale = context.scale;
        widths.add(200.w);
        return Text('${scale.scaleWidth}', textDirection: TextDirection.ltr);
      },
    );

    await tester.pumpWidget(wrap(const Size(200, 200), probe));
    await tester.pumpWidget(wrap(const Size(400, 400), probe));

    expect(widths, [100, 200]);
  });

  testWidgets('a screen that does NOT subscribe keeps a stale static .w', (
    tester,
  ) async {
    final widths = <double>[];
    final probe = Builder(
      builder: (context) {
        widths.add(200.w);
        return const SizedBox();
      },
    );

    await tester.pumpWidget(wrap(const Size(200, 200), probe));
    await tester.pumpWidget(wrap(const Size(400, 400), probe));

    expect(widths, [100]);
  });
}
