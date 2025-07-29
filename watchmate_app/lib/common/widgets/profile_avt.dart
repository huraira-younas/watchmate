import 'package:watchmate_app/common/widgets/cache_image.dart';
import 'package:flutter/material.dart';

class ProfileAvt extends StatelessWidget {
  final Color? activeColor;
  final bool showBorder;
  final bool isActive;
  final double size;
  final String url;

  const ProfileAvt({
    this.activeColor,
    this.showBorder = false,
    this.isActive = false,
    required this.size,
    required this.url,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholderColor = theme.iconTheme.color?.withValues(alpha: 0.3);
    final borderColor = theme.cardColor;

    final backgroundColor = theme.colorScheme.surface.withValues(alpha: 0.5);
    final statusColor = activeColor ?? Colors.green;

    final icon = Center(
      child: Icon(
        Icons.person_rounded,
        color: placeholderColor,
        size: size / 1.5,
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        if (showBorder)
          Container(
            height: size - 1,
            width: size - 1,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: borderColor,
            ),
          ),
        Container(
          height: showBorder ? size - 4 : size,
          width: showBorder ? size - 4 : size,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: CacheImage(
            placeHolder: icon,
            errorWidget: icon,
            fit: BoxFit.cover,
            url: url,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 2,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isActive ? 1 : 0,
            child: Container(
              height: 12,
              width: 12,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 1.7,
                ),
                shape: BoxShape.circle,
                color: statusColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
