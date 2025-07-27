import 'package:flutter/widgets.dart';

extension PaddingX on Widget {
  Widget padAll(double value) => Padding(
        padding: EdgeInsets.all(value),
        child: this,
      );

  Widget padSym({double h = 0, double v = 0}) => Padding(
        padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
        child: this,
      );

  Widget padOnly({double l = 0, double t = 0, double r = 0, double b = 0}) =>
      Padding(
        padding: EdgeInsets.only(left: l, top: t, right: r, bottom: b),
        child: this,
      );
}
