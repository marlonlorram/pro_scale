import 'package:flutter/widgets.dart';

enum DesignOrientation { portrait, landscape }

class ProScaleCore {
  static final ProScaleCore _instance = ProScaleCore._internal();
  factory ProScaleCore() => _instance;
  ProScaleCore._internal();

  double _designWidth = 0;
  double _designHeight = 0;
  double _screenWidth = 0;
  double _screenHeight = 0;

  DesignOrientation _designOrientation = DesignOrientation.portrait;
  bool _isInitialized = false;

  double _maxScaleFactor = 1.5;

  TextScaler _textScaler = TextScaler.noScaling;
  bool _respectSystemTextScale = true;

  bool get isInitialized => _isInitialized;

  void init({
    required double designWidth,
    required double designHeight,
    required Size screenSize,
    DesignOrientation designOrientation = DesignOrientation.portrait,
    double maxScaleFactor = 1.5,
    bool respectSystemTextScale = true,
  }) {
    _designWidth = designWidth;
    _designHeight = designHeight;
    _designOrientation = designOrientation;
    _maxScaleFactor = maxScaleFactor;
    _respectSystemTextScale = respectSystemTextScale;

    _updateScreenSize(screenSize);
    _isInitialized = true;
  }

  void _updateScreenSize(Size screenSize) {
    _screenWidth = screenSize.width;
    _screenHeight = screenSize.height;
  }

  void updateScreenSize(Size screenSize) {
    _updateScreenSize(screenSize);
  }

  void updateTextScaler(TextScaler textScaler) {
    _textScaler = textScaler;
  }

  bool get _shouldSwapAxes {
    final bool isScreenPortrait = _screenHeight >= _screenWidth;
    final bool isDesignPortrait =
        _designOrientation == DesignOrientation.portrait;
    return isScreenPortrait != isDesignPortrait;
  }

  double get _effectiveDesignWidth =>
      _shouldSwapAxes ? _designHeight : _designWidth;

  double get _effectiveDesignHeight =>
      _shouldSwapAxes ? _designWidth : _designHeight;

  // Falls back to 1.0 when either dimension is unusable: a non-positive design
  // size divides by zero, and a non-positive screen size (e.g. an unmeasured
  // first frame) would otherwise scale everything to zero (invisible).
  double _rawScale(double screen, double design) =>
      (screen <= 0 || design <= 0) ? 1.0 : screen / design;

  double get _rawScaleWidth => _rawScale(_screenWidth, _effectiveDesignWidth);
  double get _rawScaleHeight => _rawScale(_screenHeight, _effectiveDesignHeight);

  double get scaleWidth =>
      _isInitialized ? _rawScaleWidth.clamp(0.0, _maxScaleFactor) : 1.0;

  double get scaleHeight =>
      _isInitialized ? _rawScaleHeight.clamp(0.0, _maxScaleFactor) : 1.0;

  double setWidth(double size) => size * scaleWidth;
  double setHeight(double size) => size * scaleHeight;

  double setRadius(double radius) => radius * scaleWidth;

  double setSp(double fontSize) {
    final double designScale = (scaleWidth * 0.6) + (scaleHeight * 0.4);
    final double scaled = fontSize * designScale;

    return _respectSystemTextScale ? _textScaler.scale(scaled) : scaled;
  }

  @visibleForTesting
  void reset() {
    _designWidth = 0;
    _designHeight = 0;
    _screenWidth = 0;
    _screenHeight = 0;
    _designOrientation = DesignOrientation.portrait;
    _maxScaleFactor = 1.5;
    _textScaler = TextScaler.noScaling;
    _respectSystemTextScale = true;
    _isInitialized = false;
  }
}
