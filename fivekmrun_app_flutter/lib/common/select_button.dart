import 'package:flutter/material.dart';

class SelectButton extends StatelessWidget {
  final Function onPressed;
  final bool selected;
  final String text;

  const SelectButton(
      {Key? key,
      required this.onPressed,
      required this.selected,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: this.selected
            ? ElevatedButton(
                child: Text(
                  this.text,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                onPressed: () => this.onPressed(),
              )
            : OutlinedButton(
                child: Text(
                  this.text,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                onPressed: () => this.onPressed(),
              ),
      ),
    );
  }
}
