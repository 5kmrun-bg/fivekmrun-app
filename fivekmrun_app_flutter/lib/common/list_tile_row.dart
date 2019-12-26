import 'package:flutter/material.dart';

class ListTileRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const ListTileRow({Key key, this.icon, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        if (icon != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Icon(
              icon,
              color: theme.accentColor,
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
