import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final double padding;
  final double margin;
  final Widget child;
  const CustomCard({
    required this.child,
    this.padding = 10.0,
    this.margin = 10.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding:  EdgeInsets.all(margin),
      margin: EdgeInsets.all(margin),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.highlightColor, width: 1),
        color: theme.cardColor,
      ),
      child: child,
    );
  }
}
