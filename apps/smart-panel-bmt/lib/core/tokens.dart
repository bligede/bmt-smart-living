import 'package:flutter/material.dart';

abstract final class BmtColors {
  static const green = Color(0xFF04FB2D);
  static const green50 = Color(0xFFEAFEEF);
  static const green300 = Color(0xFF5CF878);
  static const green700 = Color(0xFF15803D);
  static const green900 = Color(0xFF0E3A1C);
  static const ink950 = Color(0xFF141414);
  static const ink900 = Color(0xFF1A1A1A);
  static const anchor = Color(0xFF282828);
  static const ink = Color(0xFF373435);
  static const ink700 = Color(0xFF4A4848);
  static const secondary = Color(0xFF615F60);
  static const mutedDark = Color(0xFFA9ADAB);
  static const onDark = Color(0xFFF2F4F3);
  static const slate50 = Color(0xFFF6F7F7);
  static const slate200 = Color(0xFFE0E2E2);
  static const safe = Color(0xFF14622F);
  static const attention = Color(0xFFA85B12);
  static const attentionBg = Color(0xFFFBF1E4);
  static const attentionDark = Color(0xFFE8A862);
  static const danger = Color(0xFFA82828);
  static const dangerBg = Color(0xFFFBEBEB);
  static const dangerDark = Color(0xFFFF8A8A);
  static const info = Color(0xFF2B5C9C);
  static const infoBg = Color(0xFFEAF0F8);
  static const infoDark = Color(0xFF7FB0EC);
}

extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get panel => isDark ? BmtColors.ink900 : BmtColors.slate50;
  Color get line => isDark ? BmtColors.ink700 : BmtColors.slate200;
  Color get muted => isDark ? BmtColors.mutedDark : BmtColors.secondary;
  Color get accent => isDark ? BmtColors.green300 : BmtColors.green700;
}
