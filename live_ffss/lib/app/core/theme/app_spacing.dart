import 'package:flutter/widgets.dart';

abstract class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets pageAll = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
}
