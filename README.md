# pro_scale

Size, spacing, radius and font scaling for Flutter that adapts to the screen —
with **automatic orientation handling** and **accessibility-aware font sizing**.

You design against a fixed reference size (e.g. a 375×812 mockup) and `pro_scale`
maps every dimension to the real screen. Unlike most scalers, it swaps the
design axes when the screen orientation differs from the design's, and its font
scaling still respects the user's system "larger text" setting.

## Features

- **Ratio-based scaling** for width, height, radius and fonts from a single design size.
- **Automatic orientation swap** — a portrait design maps onto a landscape screen (and vice-versa) without a second mockup.
- **Clamped up-scaling** via `maxScaleFactor`, so layouts don't blow up on tablets/large screens.
- **Accessibility-aware `sp`** — design scaling is layered *under* the system `TextScaler`, so accessibility font settings keep working (opt-out available).
- **Two usage modes** — a zero-boilerplate static API (`100.w`) and a reactive API (`context.scale`) that rebuilds on rotation/resize.

## Getting started

Add the dependency:

```yaml
dependencies:
  pro_scale: ^0.0.1
```

```bash
flutter pub add pro_scale
```

Wrap your app once with `ProScaleInit`, passing your design (mockup) size. The
easiest place is the `MaterialApp.builder`, which puts it below the app's
`MediaQuery`:

```dart
import 'package:flutter/material.dart';
import 'package:pro_scale/pro_scale.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => ProScaleInit(
        designWidth: 375,
        designHeight: 812,
        child: child!,
      ),
      home: const HomePage(),
    );
  }
}
```

> `ProScaleInit` must sit under a `MediaQuery` (it reads the live size and text
> scale from it). Inside `MaterialApp.builder` that's already guaranteed.

## Usage

### Static API (`num` extensions)

Concise and allocation-free — great for one-off layout values:

```dart
Container(
  width: 200.w,        // scaled width
  height: 120.h,       // scaled height
  padding: EdgeInsets.all(16.w),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12.r), // scaled radius
  ),
  child: Text('Hello', style: TextStyle(fontSize: 16.sp)), // scaled font
);
```

| Extension | Scales by | Typical use |
|-----------|-----------|-------------|
| `.w`      | width ratio  | widths, horizontal padding |
| `.h`      | height ratio | heights, vertical padding |
| `.r`      | width ratio  | border radius, icon sizes |
| `.sp`     | font ratio + system text scale | font sizes |

### Reactive API (`context.scale`)

The static extensions read the current scale imperatively — they recompute the
next time the widget rebuilds, but they **don't trigger a rebuild on their own**.
When a widget must reflow as the screen size or system text scale changes (e.g.
rotation), read the scale through the context so it subscribes to updates:

```dart
@override
Widget build(BuildContext context) {
  final scale = context.scale; // subscribes to size / text-scale changes
  return SizedBox(
    width: scale.setWidth(200),
    child: Text('Reflows on rotate', style: TextStyle(fontSize: scale.setSp(16))),
  );
}
```

`ProScale.of(context)` is the explicit form of `context.scale`.

> **Rule of thumb:** use `100.w` for static layout; use `context.scale.setWidth(100)`
> when the widget needs to react to orientation/size changes by itself.

#### Keep the static helpers in sync

The `.w`/`.h`/`.sp`/`.r` extensions don't subscribe to anything, so a widget
that only uses them won't rebuild when the screen settles or rotates (it can
even render at the wrong size on the very first frame). Call `context.scale`
**once at the top of a screen** so the whole screen rebuilds on changes — then
every `.w` below it stays correct:

```dart
@override
Widget build(BuildContext context) {
  context.scale; // subscribe once; keeps the `.w` helpers below in sync
  return Column(
    children: [
      SizedBox(width: 220.w, height: 120.h),
      Text('Title', style: TextStyle(fontSize: 18.sp)),
    ],
  );
}
```

### Orientation

`designOrientation` tells `pro_scale` which way your mockup was drawn. When the
screen orientation differs, the design width/height are swapped before scaling,
so a single portrait mockup also fits a landscape screen:

```dart
ProScaleInit(
  designWidth: 375,
  designHeight: 812,
  designOrientation: DesignOrientation.portrait, // default
  child: child!,
);
```

### Limiting up-scale

`maxScaleFactor` (default `1.5`) caps how much elements can grow, keeping
proportions sane on large screens:

```dart
ProScaleInit(
  designWidth: 375,
  designHeight: 812,
  maxScaleFactor: 1.3,
  child: child!,
);
```

### Accessibility / font scaling

By default `.sp` layers the user's system text scale on top of the design
scale, so the OS "larger text" setting keeps working. To use design scaling
only (ignore the system setting), opt out:

```dart
ProScaleInit(
  designWidth: 375,
  designHeight: 812,
  respectSystemTextScale: false,
  child: child!,
);
```

## How scaling works

- `scaleWidth = (screenWidth / effectiveDesignWidth)` clamped to `[0, maxScaleFactor]`; `scaleHeight` is analogous.
- `effectiveDesign*` swaps the design's width/height when the screen and design orientations differ.
- `setSp(size)` uses a weighted blend (`0.6 * scaleWidth + 0.4 * scaleHeight`) and then applies the system `TextScaler` (unless opted out).
- Before `init`, or for a non-positive design dimension, the scale falls back to `1.0`.

## Limitations

- `ProScaleCore` is a process-wide singleton, so the app uses a single design
  configuration. Nested scopes with different design sizes aren't supported.
- `ProScaleInit` must be a descendant of a `MediaQuery`.

## License

See [LICENSE](LICENSE).
