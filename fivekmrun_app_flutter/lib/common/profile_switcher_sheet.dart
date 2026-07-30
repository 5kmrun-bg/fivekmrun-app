import 'package:fivekmrun_flutter/common/profile_switcher.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/constants.dart' as constants;
import 'package:fivekmrun_flutter/state/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Quick switcher: lists every saved profile, plus "Add profile" and "Manage
/// profiles" — the entry point is the active profile's avatar/name (see
/// `profile.dart`).
///
/// [callerContext] is the screen that opened the sheet (e.g. `profile.dart`)
/// — every action below dismisses the sheet first and then acts using
/// *that* context, never the sheet's own builder context, which becomes
/// invalid the moment the sheet starts closing.
Future<void> showProfileSwitcherSheet(BuildContext callerContext) {
  return showModalBottomSheet<void>(
    context: callerContext,
    isScrollControlled: true,
    builder: (sheetContext) =>
        _ProfileSwitcherSheet(callerContext: callerContext),
  );
}

class _ProfileSwitcherSheet extends StatelessWidget {
  final BuildContext callerContext;

  const _ProfileSwitcherSheet({Key? key, required this.callerContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authRes = Provider.of<AuthenticationResource>(context);
    final profiles = authRes.profiles;
    final activeId = authRes.activeProfileId;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.profile_switcher_title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final profile in profiles)
            _ProfileRow(
              profile: profile,
              isActive: profile.userId == activeId,
              onSelect: () {
                Navigator.of(context).pop();
                switchToProfile(callerContext, profile.userId);
              },
            ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.profile_switcher_add_profile),
            enabled: profiles.length < constants.maxProfiles,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(callerContext, rootNavigator: true)
                  .pushNamed('add-profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts),
            title: Text(l10n.profile_switcher_manage_profiles),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(callerContext, rootNavigator: true)
                  .pushNamed('manage-profiles');
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final Profile profile;
  final bool isActive;
  final VoidCallback onSelect;

  const _ProfileRow({
    Key? key,
    required this.profile,
    required this.isActive,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName =
        profile.name.isNotEmpty ? profile.name : profile.userId.toString();

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: profile.avatarUrl.isNotEmpty
            ? NetworkImage(profile.avatarUrl)
            : null,
        child: profile.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
      ),
      title: Text(displayName),
      subtitle: Text(profile.type == ProfileType.password
          ? l10n.profile_switcher_type_password
          : l10n.profile_switcher_type_id_only),
      trailing: isActive ? const Icon(Icons.check) : null,
      onTap: isActive ? null : onSelect,
    );
  }
}
