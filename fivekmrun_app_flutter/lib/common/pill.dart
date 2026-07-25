import 'package:flutter/material.dart';

/// A small rounded label chip ("pill") used to tag cards across the app —
/// the run type on run cards, and the XL / Kids markers on future-event
/// cards. Solid background with bold, compact text; callers supply the label
/// and colors so the shape and typography stay consistent everywhere.
class Pill extends StatelessWidget {
  const Pill({
    Key? key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12.0,
        ),
      ),
    );
  }
}
