import 'package:flutter/material.dart';

/// A small rounded label chip ("pill") used to tag cards across the app —
/// the run type on run cards, and the XL / Kids markers on future-event
/// cards. Solid background with bold, compact text; callers supply the label
/// and colors so the shape and typography stay consistent everywhere.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

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

/// XLrun marker — used on both run cards and future-event cards.
class XLPill extends StatelessWidget {
  const XLPill({super.key});

  @override
  Widget build(BuildContext context) {
    return const Pill(
      label: "XL",
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }
}

/// KidsRun marker — used on future-event cards.
class KidsPill extends StatelessWidget {
  const KidsPill({super.key});

  @override
  Widget build(BuildContext context) {
    return const Pill(
      label: "Kids",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }
}

/// Official (Saturday 5kmrun) marker — used on run cards.
class OfficialPill extends StatelessWidget {
  const OfficialPill({super.key});

  @override
  Widget build(BuildContext context) {
    return const Pill(
      label: "5kmrun",
      backgroundColor: Colors.white,
      textColor: Colors.black87,
    );
  }
}

/// Selfie run marker — used on run cards. Uses the theme accent so it stays
/// consistent with the app's palette.
class SelfiePill extends StatelessWidget {
  const SelfiePill({super.key});

  @override
  Widget build(BuildContext context) {
    return Pill(
      label: "Selfie",
      backgroundColor: Theme.of(context).colorScheme.secondary,
      textColor: Colors.white,
    );
  }
}
