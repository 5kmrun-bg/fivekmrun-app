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
        child: selected
            ? ElevatedButton(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                onPressed: () => onPressed(),
              )
            : OutlinedButton(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                onPressed: () => onPressed(),
              ),
      ),
    );
  }
}
