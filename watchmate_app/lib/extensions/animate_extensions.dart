import 'package:watchmate_app/constants/app_constants.dart';
import 'package:flutter/material.dart';

class _DelayedWidget extends StatefulWidget {
  final Duration delay;
  final Widget child;

  const _DelayedWidget({
    this.delay = const Duration(milliseconds: AppConstants.animDur),
    required this.child,
  });

  @override
  State<_DelayedWidget> createState() => _DelayedWidgetState();
}

class _DelayedWidgetState extends State<_DelayedWidget>
    with SingleTickerProviderStateMixin {
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: AppConstants.animDur),
      opacity: opacity,
      child: widget.child,
    );
  }
}

extension ProAnimate on Widget {
  Widget hero(Object tag, {Key? key, bool transitionOnUserGestures = false}) {
    return Hero(
      transitionOnUserGestures: transitionOnUserGestures,
      tag: tag,
      key: key,
      child: this,
    );
  }

  Widget fadeIn({
    Duration duration = const Duration(milliseconds: AppConstants.animDur),
    Curve curve = Curves.easeInOut,
    double begin = 0,
    double end = 1,
    Key? key,
  }) {
    return TweenAnimationBuilder<double>(
      builder: (_, value, child) => Opacity(opacity: value, child: child),
      key: key ?? ValueKey('$hashCode-fadeIn'),
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      child: this,
    );
  }

  Widget slideY(
    double offsetY, {
    Duration duration = const Duration(milliseconds: AppConstants.animDur),
    Curve curve = Curves.easeOut,
    Key? key,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: Offset(0, offsetY / 100), end: Offset.zero),
      builder: (_, v, c) => Transform.translate(offset: v, child: c),
      key: key ?? ValueKey('$hashCode-slideY'),
      duration: duration,
      curve: curve,
      child: this,
    );
  }

  Widget slideX(
    double offsetX, {
    Duration duration = const Duration(milliseconds: AppConstants.animDur),
    Curve curve = Curves.easeOut,
    Key? key,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: Offset(offsetX / 100, 0), end: Offset.zero),
      builder: (_, v, c) => Transform.translate(offset: v, child: c),
      key: key ?? ValueKey('$hashCode-slideX'),
      duration: duration,
      curve: curve,
      child: this,
    );
  }

  Widget scale({
    Duration duration = const Duration(milliseconds: AppConstants.animDur),
    Curve curve = Curves.easeOutBack,
    double begin = 0.8,
    double end = 1.0,
    Key? key,
  }) {
    return TweenAnimationBuilder<double>(
      builder: (_, value, child) => Transform.scale(scale: value, child: child),
      key: key ?? ValueKey('$hashCode-scale'),
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      child: this,
    );
  }

  Widget rotate({
    Duration duration = const Duration(milliseconds: AppConstants.animDur),
    Curve curve = Curves.easeInOut,
    double turns = 1.0,
    Key? key,
  }) {
    return TweenAnimationBuilder<double>(
      builder: (_, v, c) => Transform.rotate(angle: v * 6.28318, child: c),
      key: key ?? ValueKey('$hashCode-rotate'),
      tween: Tween(begin: 0, end: turns),
      duration: duration,
      curve: curve,
      child: this,
    );
  }

  Widget fadeSlide({
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutCubic,
    double offsetY = 0,
    double offsetX = 0,
    Key? key,
  }) {
    return TweenAnimationBuilder<double>(
      key: key ?? ValueKey('$hashCode-fadeSlide-$offsetX-$offsetY'),
      tween: Tween(begin: 1, end: 0),
      duration: duration,
      curve: curve,
      builder: (_, value, child) => Opacity(
        opacity: 1 - value,
        child: Transform.translate(
          offset: Offset(value * offsetX, value * offsetY),
          child: child,
        ),
      ),
      child: this,
    );
  }

  Widget withDelay(int index, {int intervalMs = 100}) {
    final delay = Duration(milliseconds: index * intervalMs);
    return _DelayedWidget(delay: delay, child: this);
  }
}
