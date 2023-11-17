import 'package:flutter/material.dart';

class DetailsTile extends StatelessWidget {
  final String title;
  final String value;
  final Color accentColor;
  const DetailsTile(
      {Key? key,
      required this.title,
      required this.value,
      required this.accentColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(this.title, style: textTheme.bodyMedium),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Text(
            this.value,
            style: TextStyle(color: accentColor, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
