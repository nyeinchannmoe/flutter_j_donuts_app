/// Width-based phone classes.
///
/// Reference devices: 320x568 and 360x640 are compact, 375x667 and
/// 390x844 are regular, 430x932 is expanded.
enum ScreenClass {
  compact,
  regular,
  expanded;

  static ScreenClass fromWidth(double width) {
    if (width < LayoutBreakpoints.regularMinWidth) return compact;
    if (width < LayoutBreakpoints.expandedMinWidth) return regular;
    return expanded;
  }
}

abstract final class LayoutBreakpoints {
  static const double regularMinWidth = 370;
  static const double expandedMinWidth = 414;

  /// Heights below this (4.7 inch phones and smaller) get tighter layouts.
  static const double shortHeightMax = 700;

  /// Width the designs were drawn at; scale factors are relative to it.
  static const double designWidth = 390;
}
