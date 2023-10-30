import 'package:flutter/material.dart';

const double SIZE = 150;

class Avatar extends StatelessWidget {
  final String url;
  const Avatar({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
      child: SizedBox(
        width: SIZE,
        height: SIZE,
        child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.secondary),
                padding: EdgeInsets.all(2),
                child: (url.isNotEmpty)
                    ? CircleAvatar(
                        radius: SIZE / 2, backgroundImage: NetworkImage(url))
                    : Container(),
              )
            ,
      ),
    );
  }
}
