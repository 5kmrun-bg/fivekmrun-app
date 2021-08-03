import 'package:flutter/material.dart';

class ListTileRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final int iconSize;
  const ListTileRow(
      {Key? key,
      required this.icon,
      required this.text,
      this.iconColor,
      this.iconSize = 18})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = this.iconColor != null ? this.iconColor : theme.accentColor;
    return Row(
      children: <Widget>[
        if (icon != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Icon(
              icon,
              color: color,
              size: this.iconSize.toDouble(),
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(text, style: theme.textTheme.subtitle),
          ),
        ),
      ],
    );
  }
}
