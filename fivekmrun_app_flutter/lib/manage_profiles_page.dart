import 'package:fivekmrun_flutter/common/profile_switcher.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/state/authentication_resource.dart';
import 'package:fivekmrun_flutter/state/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Lists every saved profile with a remove action. Reordering is out of
/// scope for #184 — the acceptance criteria only call for add/switch/remove.
class ManageProfilesPage extends StatelessWidget {
  const ManageProfilesPage({Key? key}) : super(key: key);

  Future<void> _confirmAndRemove(
      BuildContext context, Profile profile, AppLocalizations l10n) async {
    final displayName =
        profile.name.isNotEmpty ? profile.name : profile.userId.toString();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.manage_profiles_page_remove_title),
        content: Text(l10n.manage_profiles_page_remove_content(displayName)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.manage_profiles_page_remove),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await removeProfileFromSwitcher(context, profile.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authRes = Provider.of<AuthenticationResource>(context);
    final activeId = authRes.activeProfileId;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text(l10n.profile_switcher_manage_profiles),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          for (final profile in authRes.profiles)
            ListTile(
              leading: CircleAvatar(
                backgroundImage: profile.avatarUrl.isNotEmpty
                    ? NetworkImage(profile.avatarUrl)
                    : null,
                child:
                    profile.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
              ),
              title: Text(profile.name.isNotEmpty
                  ? profile.name
                  : profile.userId.toString()),
              subtitle: Text(profile.type == ProfileType.password
                  ? l10n.profile_switcher_type_password
                  : l10n.profile_switcher_type_id_only),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmAndRemove(context, profile, l10n),
              ),
              selected: profile.userId == activeId,
            ),
        ],
      ),
    );
  }
}
