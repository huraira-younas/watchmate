import 'package:watchmate_app/extensions/widget_extensions.dart';
import 'package:flutter/material.dart';

class BottomSheetItem {
  final VoidCallback onTap;
  final IconData icon;
  final String title;

  BottomSheetItem({
    required this.onTap,
    required this.title,
    required this.icon,
  });
}

Future<void> showCustomBottomSheet({
  required List<BottomSheetItem> items,
  required BuildContext context,
}) {
  return showModalBottomSheet(
    showDragHandle: true,
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final theme = Theme.of(context);
      return Material(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        color: theme.cardColor,
        child: ListView(
          shrinkWrap: true,
          children: List.generate(items.length * 2 - 1, (i) {
            if (i.isOdd) {
              return Divider(
                color: theme.disabledColor.withValues(alpha: 0.1),
                height: 1,
              );
            }
            final index = i ~/ 2;
            final item = items[index];
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              onTap: () {
                Navigator.pop(context);
                item.onTap();
              },
            );
          }),
        ),
      ).padAll(6);
    },
  );
}
