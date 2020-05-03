import 'package:flutter/material.dart';

class DetailsTile extends StatelessWidget {
  final String title;
  final String value;
  final Color accentColor;
  const DetailsTile({Key key, this.title, this.value, this.accentColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subHeadStyle = Theme.of(context).textTheme.body1;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(this.title, style: subHeadStyle),
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
