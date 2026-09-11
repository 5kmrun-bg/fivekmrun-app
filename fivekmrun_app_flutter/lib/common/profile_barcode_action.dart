import 'package:fivekmrun_flutter/custom_icons.dart';
import 'package:flutter/material.dart';

/// The barcode icon in the top-left corner of the profile header. Always
/// left-aligned so it hugs the header's leading edge, mirroring how
/// [ProfileHeaderActions] hugs the trailing edge on the other side.
class ProfileBarcodeAction extends StatelessWidget {
  const ProfileBarcodeAction({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        IconButton(
          icon: const Icon(CustomIcons.barcode),
          onPressed: onPressed,
        ),
      ],
    );
  }
}
