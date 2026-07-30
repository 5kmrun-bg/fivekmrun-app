import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:fivekmrun_flutter/state/whats_new_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show AssetBundle;
import 'package:package_info_plus/package_info_plus.dart';

/// Lists the last few versions' highlights, newest first, reachable from
/// Settings. Reacts to a locale switch while open because [build] re-reads
/// `Localizations.localeOf(context)` on every rebuild rather than caching it.
class WhatsNewPage extends StatefulWidget {
  /// Injectable for tests; defaults to a real resource in production.
  final WhatsNewResource resource;
  final Future<PackageInfo> Function() packageInfoProvider;

  /// Test-only seam for [resource]'s asset load — production always reads
  /// the real bundled asset.
  final AssetBundle? bundle;

  WhatsNewPage({
    Key? key,
    WhatsNewResource? resource,
    Future<PackageInfo> Function()? packageInfoProvider,
    this.bundle,
  })  : resource = resource ?? WhatsNewResource(),
        packageInfoProvider = packageInfoProvider ?? PackageInfo.fromPlatform,
        super(key: key);

  @override
  _WhatsNewPageState createState() => _WhatsNewPageState();
}

class _WhatsNewPageState extends State<WhatsNewPage> {
  bool _loading = true;
  String? _currentVersion;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait(<Future<dynamic>>[
      widget.resource.load(bundle: widget.bundle),
      widget.packageInfoProvider(),
    ]);
    if (!mounted) return;
    setState(() {
      _currentVersion = (results[1] as PackageInfo).version;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text(l10n.whats_new_page_title),
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                if (_currentVersion != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      l10n.whats_new_page_current_version(_currentVersion!),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                for (final entry in widget.resource.recentEntries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          entry.version,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        for (final bullet in entry.bulletsFor(localeCode))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text("• $bullet"),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
