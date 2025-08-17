import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final BoxConstraints? constraints;
  final double padding;
  final double margin;
  final double? width;
  final double radius;
  final Widget child;
  const CustomCard({
    this.width = double.maxFinite,
    required this.child,
    this.padding = 10.0,
    this.margin = 10.0,
    this.radius = 10.0,
    this.constraints,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: constraints,
      padding: EdgeInsets.all(padding),
      margin: EdgeInsets.all(margin),
      clipBehavior: Clip.antiAlias,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: theme.highlightColor, width: 1),
        color: theme.cardColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
