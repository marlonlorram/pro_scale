import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pro_scale/pro_scale.dart';

void main() {
  setUp(() => ProScaleCore().reset());

  group('ProScaleCore', () {
    test('returns a neutral 1.0 scale before init', () {
      final core = ProScaleCore();
      expect(core.isInitialized, isFalse);
      expect(core.scaleWidth, 1.0);
      expect(core.scaleHeight, 1.0);
      expect(core.setWidth(100), 100);
      expect(core.setHeight(100), 100);
      expect(core.setSp(10), 10);
      expect(core.setRadius(20), 20);
    });

    test('scales by the screen/design ratio', () {
      ProScaleCore().init(
        designWidth: 400,
        designHeight: 800,
        screenSize: const Size(200, 400),
      );
      expect(ProScaleCore().setWidth(100), 50);
      expect(ProScaleCore().setHeight(100), 50);
      expect(ProScaleCore().setRadius(20), 10);
      expect(ProScaleCore().setSp(10), 5);
    });

    test('clamps the up-scale to maxScaleFactor', () {
      ProScaleCore().init(
        designWidth: 100,
        designHeight: 100,
        screenSize: const Size(1000, 1000),
        maxScaleFactor: 1.5,
      );
      expect(ProScaleCore().scaleWidth, 1.5);
      expect(ProScaleCore().setWidth(100), 150);
    });

    test('swaps axes for a portrait design on a landscape screen', () {
      ProScaleCore().init(
        designWidth: 400,
        designHeight: 800,
        screenSize: const Size(800, 400),
        maxScaleFactor: 3,
      );
      expect(ProScaleCore().setWidth(100), 100);
      expect(ProScaleCore().setHeight(100), 100);
    });

    test('swaps axes for a landscape design on a portrait screen', () {
      ProScaleCore().init(
        designWidth: 800,
        designHeight: 400,
        screenSize: const Size(400, 800),
        designOrientation: DesignOrientation.landscape,
        maxScaleFactor: 3,
      );

      expect(ProScaleCore().setWidth(100), 100);
      expect(ProScaleCore().setHeight(100), 100);
    });

    test('falls back to 1.0 instead of dividing by zero', () {
      ProScaleCore().init(
        designWidth: 0,
        designHeight: 0,
        screenSize: const Size(100, 100),
      );
      expect(ProScaleCore().scaleWidth, 1.0);
      expect(ProScaleCore().scaleHeight, 1.0);
      expect(ProScaleCore().setWidth(50), 50);
    });

    test('setSp layers the system text scaler on top of the design scale', () {
      ProScaleCore().init(
        designWidth: 400,
        designHeight: 800,
        screenSize: const Size(400, 800),
      );
      ProScaleCore().updateTextScaler(const TextScaler.linear(2));
      expect(ProScaleCore().setSp(10), 20);
    });

    test('setSp ignores the system text scaler when opted out', () {
      ProScaleCore().init(
        designWidth: 400,
        designHeight: 800,
        screenSize: const Size(400, 800),
        respectSystemTextScale: false,
      );
      ProScaleCore().updateTextScaler(const TextScaler.linear(2));
      expect(ProScaleCore().setSp(10), 10);
    });
  });

  group('num extensions', () {
    test('delegate to the core scale', () {
      ProScaleCore().init(
        designWidth: 400,
        designHeight: 800,
        screenSize: const Size(200, 400),
      );
      expect(100.w, 50);
      expect(100.h, 50);
      expect(20.r, 10);
      expect(10.sp, 5);
    });
  });

  group('ProScaleInit', () {
    Widget wrap(Size size, Widget child, {TextScaler? textScaler}) =>
        MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: textScaler ?? TextScaler.noScaling,
          ),
          child: child,
        );

    testWidgets('initializes the core from the ambient MediaQuery', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const Size(200, 400),
          ProScaleInit(
            designWidth: 400,
            designHeight: 800,
            child: const SizedBox(),
          ),
        ),
      );

      expect(ProScaleCore().isInitialized, isTrue);
      expect(ProScaleCore().setWidth(100), 50);
    });

    testWidgets('subscribers rebuild with a fresh scale when the size changes', (
      tester,
    ) async {
      final widths = <double>[];
      final probe = Builder(
        builder: (context) {
          widths.add(ProScale.of(context).setWidth(100));
          return const SizedBox();
        },
      );
      final app = ProScaleInit(
        designWidth: 400,
        designHeight: 400,
        child: probe,
      );

      await tester.pumpWidget(wrap(const Size(200, 200), app));
      await tester.pumpWidget(wrap(const Size(400, 400), app));

      expect(widths.first, 50);
      expect(widths.last, 100);
    });

    testWidgets('feeds the system text scaler into setSp', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Size(400, 800),
          ProScaleInit(
            designWidth: 400,
            designHeight: 800,
            child: const SizedBox(),
          ),
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(ProScaleCore().setSp(10), 20);
    });
  });
}
