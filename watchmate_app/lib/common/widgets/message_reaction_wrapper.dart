import 'package:watchmate_app/utils/logger.dart';
import 'package:flutter/material.dart';

class MessageReactionWrapper extends StatefulWidget {
  final Function(String emoji) onSelect;
  final bool isSender;
  final Widget child;

  const MessageReactionWrapper({
    required this.onSelect,
    required this.isSender,
    required this.child,
    super.key,
  });

  @override
  State<MessageReactionWrapper> createState() => _MessageReactionWrapperState();
}

class _MessageReactionWrapperState extends State<MessageReactionWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _messageKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _showReactionPopover() {
    if (_overlayEntry != null) return;

    final render = _messageKey.currentContext?.findRenderObject() as RenderBox;
    final offset = render.localToGlobal(Offset.zero);
    final w = MediaQuery.sizeOf(context).width;
    final size = render.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: <Widget>[
          FadeTransition(
            opacity: CurvedAnimation(
              curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
              parent: _animationController,
            ),
            child: GestureDetector(
              onTap: _removeReactionPopover,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.black26),
            ),
          ),

          Positioned(
            left: widget.isSender ? null : offset.dx,
            top: offset.dy - 60,
            right: widget.isSender
                ? (MediaQuery.of(context).size.width - (offset.dx + size.width))
                : null,
            child: ReactionPopover(
              animationController: _animationController,
              onEmojiSelected: (emoji) {
                _removeReactionPopover();
                widget.onSelect(emoji);
                Logger.info(
                  message: 'User reacted with: $emoji',
                  tag: "REACTION",
                );
              },
            ),
          ),
          Positioned(
            top: offset.dy,
            left: widget.isSender ? null : offset.dx,
            right: widget.isSender ? (w - (offset.dx + size.width)) : null,
            child: Material(
              color: Colors.transparent,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: Container(
                  width: w * 0.9,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  void _removeReactionPopover() async {
    if (_overlayEntry != null) {
      await _animationController.reverse();
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showReactionPopover,
      key: _messageKey,
      child: widget.child,
    );
  }
}

class ReactionPopover extends StatelessWidget {
  final List<String> emojis = ['👍', '❤️', '😂', '😮', '😢', '😡'];
  final AnimationController animationController;
  final ValueChanged<String> onEmojiSelected;

  ReactionPopover({
    required this.animationController,
    required this.onEmojiSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 3),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(emojis.length, (index) {
            final start = index * 0.1;
            final end = start + 0.7;
            final animation = CurvedAnimation(
              parent: animationController,
              curve: Interval(
                start.clamp(0.0, 1.0),
                end.clamp(0.0, 1.0),
                curve: Curves.elasticOut,
              ),
            );
            return ScaleTransition(
              scale: animation,
              child: GestureDetector(
                onTap: () => onEmojiSelected(emojis[index]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    emojis[index],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
