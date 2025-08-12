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

Future<void> showCustomBottomSheet(
  BuildContext context, {
  required List<BottomSheetItem> items,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return ListView.separated(
        shrinkWrap: true,
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Icon(item.icon),
            title: Text(item.title),
            onTap: () {
              Navigator.pop(context);
              item.onTap();
            },
          );
        },
      );
    },
  );
}
