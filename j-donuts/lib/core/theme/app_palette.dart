import 'dart:ui';

/// Raw brand colors sampled from the designs. Only theme files read these;
/// widgets use the semantic AppColors extension.
abstract final class AppPalette {
  static const Color skyBlue = Color(0xFF55CFEA);
  static const Color skyBlueDark = Color(0xFF2FB4D3);
  static const Color brandPink = Color(0xFFEE4F9B);
  static const Color brandPinkSoft = Color(0xFFFDE7F0);
  static const Color warmCream = Color(0xFFFFF8F5);
  static const Color deepPink = Color(0xFFAF2567);
  /// Warm near-white at the top of the auth gradient.
  static const Color blushTop = Color(0xFFFFF8F5);

  /// Soft pink mid-stop of the auth gradient.
  static const Color blushMid = Color(0xFFFCE4EE);

  /// Light pink that matches the welcome hero footer plane (#FCE8F0).
  static const Color blushBottom = Color(0xFFFCE8F0);
  static const Color orange = Color(0xFFFF7F22);
  static const Color peach = Color(0xFFFFE3D3);
  /// Soft cream used behind the Home member header.
  static const Color cream = Color(0xFFFDF0E4);
  /// Stronger peach tint for avatar glow and organic header shapes.
  static const Color peachDeep = Color(0xFFFFD4B8);
  static const Color coolGray = Color(0xFFF0F2F5);
  static const Color mist = Color(0xFFE8ECF0);
  static const Color stone = Color(0xFFD5DADD);
  static const Color slate = Color(0xFF9C99A3);
  static const Color ink = Color(0xFF1F1B24);
  static const Color inkSoft = Color(0xFF2B2730);
  static const Color white = Color(0xFFFFFFFF);
  static const Color olive = Color(0xFF8DBF6A);
  static const Color violet = Color(0xFF6C5BD4);
  static const Color silver = Color(0xFFB9BEC4);
  static const Color gold = Color(0xFFF2C94C);
  static const Color platinum = Color(0xFF9ADCF0);
  static const Color danger = Color(0xFFE5484D);
  static const Color shadow = Color(0x1A1C1F26);
  static const Color scrim = Color(0x661C1F26);
  static const Color shimmerBase = Color(0xFFE6EAEC);
  static const Color shimmerHighlight = Color(0xFFF7F9FA);
}
