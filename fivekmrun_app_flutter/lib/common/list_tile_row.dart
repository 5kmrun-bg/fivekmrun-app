import 'package:flutter/material.dart';

class ListTileRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  const ListTileRow({Key key, this.icon, this.text, this.iconColor})
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
