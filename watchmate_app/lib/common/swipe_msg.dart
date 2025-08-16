import 'package:flutter/services.dart' show HapticFeedback;
import 'package:watchmate_app/constants/app_themes.dart';
import 'package:flutter/material.dart';

enum SwipeDirection { left, right, both, none }

class SwipeMsg extends StatefulWidget {
  final SwipeDirection allowedDirection;
  final double swipeThreshold;
  final VoidCallback onSwipe;
  final IconData swipeIcon;
  final Color iconColor;
  final Widget child;

  const SwipeMsg({
    this.allowedDirection = SwipeDirection.both,
    this.iconColor = AppColors.darkPrimary,
    this.swipeIcon = Icons.reply,
    this.swipeThreshold = 70.0,
    required this.onSwipe,
    required this.child,
    super.key,
  });

  @override
  State<SwipeMsg> createState() => _SwipeMsgState();
}

class _SwipeMsgState extends State<SwipeMsg> {
  late SwipeDirection allowedDirection = widget.allowedDirection;
  double _dragOffset = 0.0;
  bool _isLocked = false;

  bool get _isSwipingRight => _dragOffset > 0;
  bool get _isSwipingAllowed {
    switch (allowedDirection) {
      case SwipeDirection.right:
        return _isSwipingRight;
      case SwipeDirection.left:
        return !_isSwipingRight;
      case SwipeDirection.both:
        return true;
      case SwipeDirection.none:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double iconOpacity =
        (_dragOffset.abs() / widget.swipeThreshold).clamp(0.0, 1.0);

    final right = allowedDirection == SwipeDirection.right;
    final left = allowedDirection == SwipeDirection.left;
    final both = allowedDirection == SwipeDirection.both;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        if (right || both && _isSwipingRight)
          Positioned(
            top: 10,
            left: 16.0,
            child: Opacity(
              opacity: iconOpacity,
              child: Transform.flip(
                flipX: true,
                child: Icon(
                  widget.swipeIcon,
                  color: widget.iconColor,
                  size: 24.0,
                ),
              ),
            ),
          ),
        if (left || both && !_isSwipingRight)
          Positioned(
            top: 10,
            right: 16.0,
            child: Opacity(
              opacity: iconOpacity,
              child: Icon(
                widget.swipeIcon,
                color: widget.iconColor,
                size: 24.0,
              ),
            ),
          ),
        GestureDetector(
          onHorizontalDragStart: (_) {
            if (allowedDirection == SwipeDirection.none) return;
            if (_isLocked) {
              setState(() => _isLocked = false);
            }
          },
          onHorizontalDragUpdate: (details) {
            if (allowedDirection == SwipeDirection.none) return;
            if (!_isLocked) {
              if (_dragOffset.abs() > widget.swipeThreshold &&
                  _isSwipingAllowed) {
                _isLocked = true;
              }

              setState(() {
                _dragOffset += details.delta.dx * 0.4;
                if (!_isSwipingAllowed) {
                  _dragOffset = 0.0;
                }
              });
            }
          },
          onHorizontalDragEnd: (_) {
            if (allowedDirection == SwipeDirection.none) return;
            if (_dragOffset.abs() > widget.swipeThreshold &&
                _isSwipingAllowed) {
              HapticFeedback.mediumImpact();
              widget.onSwipe();
            }
            setState(() {
              _dragOffset = 0.0;
            });
          },
          child: Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
