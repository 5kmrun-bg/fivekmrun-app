import 'package:flutter/material.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';

/// Whether the seasonal "wrap" gift icon should show next to the settings
/// cog — the last two weeks of December through the end of January.
/// Takes an optional [now] so callers (and tests) don't depend on the
/// system clock.
bool isWrapSeasonActive([DateTime? now]) {
  final date = now ?? DateTime.now();
  return date.month == 1 || (date.month == 12 && date.day >= 15);
}

/// The action icons in the top-right corner of the profile header: the
/// seasonal "wrap" gift icon (when active) and the settings cog. Always
/// right-aligned so the cog hugs the header's trailing edge.
class ProfileHeaderActions extends StatelessWidget {
  const ProfileHeaderActions({
    super.key,
    required this.showWrapIcon,
    required this.onSettings,
    required this.onWrapTap,
  });

  final bool showWrapIcon;
  final VoidCallback onSettings;
  final VoidCallback onWrapTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        if (showWrapIcon)
          ShakeWidget(
            shakeConstant: ShakeSlowConstant1(),
            autoPlay: true,
            child: IconButton(
              icon: const Icon(Icons.redeem),
              color: Colors.red,
              onPressed: onWrapTap,
            ),
          ),
        IconButton(icon: const Icon(Icons.settings), onPressed: onSettings),
      ],
    );
  }
}
