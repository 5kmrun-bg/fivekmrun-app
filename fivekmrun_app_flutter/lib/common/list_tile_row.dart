import 'package:flutter/material.dart';

class ListTileRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final int iconSize;
  const ListTileRow(
      {super.key,
      required this.icon,
      required this.text,
      this.iconColor,
      this.iconSize = 18});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        iconColor ?? theme.colorScheme.secondary;
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Icon(
            icon,
            color: color,
            size: iconSize.toDouble(),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(text, style: theme.textTheme.titleSmall),
          ),
        ),
      ],
    );
  }
}
