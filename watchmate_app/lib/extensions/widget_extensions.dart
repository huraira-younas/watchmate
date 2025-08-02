import 'package:flutter/widgets.dart';

extension WidgetX on Widget {
  Widget padAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  Widget padSym({double h = 0, double v = 0}) => Padding(
    padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
    child: this,
  );

  Widget padOnly({double l = 0, double t = 0, double r = 0, double b = 0}) =>
      Padding(
        padding: EdgeInsets.only(left: l, top: t, right: r, bottom: b),
        child: this,
      );

  Widget onTap(
    GestureTapCallback onTap, {
    HitTestBehavior behavior = HitTestBehavior.opaque,
  }) {
    return GestureDetector(onTap: onTap, behavior: behavior, child: this);
  }

  Widget expanded({int flex = 1, Key? key}) =>
      Expanded(flex: flex, key: key, child: this);
}
