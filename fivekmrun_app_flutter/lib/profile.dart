import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:fivekmrun_flutter/charts/best_times_by_route_chart.dart';
import 'package:fivekmrun_flutter/charts/runs_by_route_chart.dart';
import 'package:fivekmrun_flutter/common/avatar.dart';
import 'package:fivekmrun_flutter/common/badges.dart';
import 'package:fivekmrun_flutter/common/legioner_status_helper.dart';
import 'package:fivekmrun_flutter/common/profile_header_actions.dart';
import 'package:fivekmrun_flutter/common/profile_switcher_sheet.dart';
import 'package:fivekmrun_flutter/common/refresh_helper.dart';
import 'package:fivekmrun_flutter/common/run_card.dart';
import 'package:fivekmrun_flutter/constants.dart';
import 'package:fivekmrun_flutter/custom_icons.dart';
import 'package:fivekmrun_flutter/events/future_events.dart'
    show XLRegistrationSection;
import 'package:fivekmrun_flutter/home.dart';
import 'package:fivekmrun_flutter/state/event_model.dart';
import 'package:fivekmrun_flutter/state/events_resource.dart';
import 'package:fivekmrun_flutter/state/run_model.dart';
import 'package:fivekmrun_flutter/state/runs_resource.dart';
import 'package:fivekmrun_flutter/state/user_resource.dart';
import 'package:fivekmrun_flutter/state/xl_stats.dart';
import 'package:fivekmrun_flutter/timekeeping/timekeeping.dart';
import 'package:fivekmrun_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'charts/runs_chart.dart';
import 'common/milestone.dart';

class ProfileDashboard extends StatelessWidget {
  const ProfileDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userResource = Provider.of<UserResource>(context);
    final runsRes = Provider.of<RunsResource>(context);

    final user = userResource.value;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final runs = runsRes.value;
    final hasAnyRuns = runs != null && runs.isNotEmpty;
    final hasOfficialRuns = runs != null &&
        runs.where((r) => r.runType == RunType.official).isNotEmpty;
    final hasSelfieRuns = runs != null &&
        runs.where((r) => r.runType == RunType.selfie).isNotEmpty;
    final xlStats = XLStats.fromRuns(runs ?? <Run>[]);
    // Promote the next XL event to anyone who has ever run one. The events
    // are already fetched for the events tab (AllFutureEventsResource is
    // loaded on home), so this adds no request.
    final nextXLEvent = xlStats == null
        ? null
        : nextUpcomingXLEvent(
            Provider.of<AllFutureEventsResource>(context).value);

    void goToSettings() {
      Navigator.of(context, rootNavigator: true).pushNamed("settings");
    }

    void goToBarcode() {
      Navigator.of(context, rootNavigator: true).pushNamed("barcode");
    }

    Widget profileBadge() {
      if (hasMaxBadge(runs)) {
        return const Image(
            height: 64,
            alignment: Alignment.bottomRight,
            image: AssetImage('assets/max-badge.png'));
      }

      if (hasSelfieBadge(runs)) {
        return const Image(
            height: 64,
            alignment: Alignment.bottomRight,
            image: AssetImage('assets/selfie-badge.png'));
      }

      return const SizedBox.shrink();
    }

    return ColorfulSafeArea(
        color: const Color.fromRGBO(66, 66, 66, 0.7),
        overflowRules: const OverflowRules.all(true),
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: RefreshIndicator(
            onRefresh: () => refreshAllData(context),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(CustomIcons.barcode),
                            onPressed: goToBarcode,
                          ),
                          MilestoneTile(
                              value: runsRes.value
                                      ?.where(
                                          (r) => r.runType == RunType.selfie)
                                      .length
                                      .toInt() ??
                                  0,
                              milestone: LegionerStatusHelper.getNextMilestone(
                                  runsRes.value
                                          ?.where((r) =>
                                              r.runType == RunType.selfie)
                                          .length
                                          .toInt() ??
                                      0),
                              title: l10n.profile_page_legionary_selfie),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: GestureDetector(
                        // The quick profile switcher (#184) — this avatar/name
                        // is the app's stand-in for an app-bar identity menu,
                        // since the Profile tab has no literal app bar.
                        onTap: () => showProfileSwitcherSheet(context),
                        child: Column(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                Avatar(url: user?.avatarUrl ?? ""),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: profileBadge(),
                                )
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    user?.name ?? "",
                                    style: textTheme.titleMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Icon(Icons.expand_more, size: 18),
                              ],
                            ),
                            const Text(""),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: <Widget>[
                          ProfileHeaderActions(
                            showWrapIcon: isWrapSeasonActive(),
                            onSettings: goToSettings,
                            onWrapTap: () => launchUrl(
                                Uri.parse(wrapUrl + user!.id.toString()),
                                mode: LaunchMode.externalApplication),
                          ),
                          MilestoneTile(
                              value: runsRes.value
                                      ?.where(
                                          (r) => r.runType == RunType.official)
                                      .length
                                      .toInt() ??
                                  0,
                              milestone: LegionerStatusHelper.getNextMilestone(
                                  runsRes.value
                                          ?.where((r) =>
                                              r.runType == RunType.official)
                                          .length
                                          .toInt() ??
                                      0),
                              title: l10n.profile_page_legionary_official),
                        ],
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [Timekeeping()],
                ),
                if (runsRes.loading) const Center(child: CircularProgressIndicator()),
                if (hasOfficialRuns)
                  buildRunsCards(context, runsRes.bestOfficialRun!,
                      runsRes.lastOfficialRun!, l10n.profile_page_official),
                if (hasSelfieRuns)
                  buildRunsCards(context, runsRes.bestSelfieRun!,
                      runsRes.lastSelfieRun!, "selfie"),
                if (xlStats != null)
                  buildXLStatsCard(xlStats, nextXLEvent),
                if (hasAnyRuns) buildRunsChartCard(runs),
                if (!runsRes.loading && !hasAnyRuns)
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Center(
                            child: Text(l10n.no_runs),
                          ),
                        ),
                      )
                    ],
                  ),
                if (hasOfficialRuns) buildRunsByRouteCard(runs),
                if (hasOfficialRuns) buildBestTimesCard(runs),
              ],
            )));
  }

  Widget buildRunsCards(
      BuildContext context, Run bestRun, Run lastRun, String runType) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: <Widget>[
        Expanded(
          child: RunCard(
            title: l10n.profile_page_last_run + runType,
            run: lastRun,
          ),
        ),
        Expanded(
          child: RunCard(
            title: l10n.profile_page_best_run + runType,
            run: bestRun,
          ),
        ),
      ],
    );
  }

  Widget buildXLStatsCard(XLStats stats, XLEvent? nextEvent) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Builder(builder: (context) {
              final theme = Theme.of(context);
              final l10n = AppLocalizations.of(context)!;
              final labelStyle = theme.textTheme.bodyMedium;
              final valueStyle = theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.secondary);

              Widget stat(String value, String label) {
                return Column(
                  children: <Widget>[
                    Text(value, style: valueStyle),
                    Text(label, style: labelStyle, textAlign: TextAlign.center),
                  ],
                );
              }

              // Deliberately lighter than ListTileRow (which styles tile
              // *titles*): this is secondary context under the stats, so it
              // uses a smaller icon and smaller body text.
              final rowTextStyle =
                  theme.textTheme.bodySmall?.copyWith(color: Colors.white);

              // [label] is always plain text; only [linkText] is tappable,
              // and only it carries the chevron marking the row as a link.
              Widget metaRow(IconData icon, String label,
                  {String? linkText, VoidCallback? onTap}) {
                return Padding(
                  // The extra 4 on the left lines this row up with the
                  // registration strip below, which sits outside the card's
                  // 12px padding and uses 16 of its own.
                  padding: const EdgeInsets.fromLTRB(4, 3, 0, 3),
                  child: Row(
                    children: <Widget>[
                      // Boxed to the registration header's 18px icon width so
                      // both labels start at the same x, while the glyph
                      // itself stays smaller and less prominent.
                      SizedBox(
                        width: 18,
                        child: Icon(icon,
                            size: 14, color: theme.colorScheme.secondary),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (linkText != null)
                        Flexible(
                          child: InkWell(
                            onTap: onTap,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    linkText,
                                    overflow: TextOverflow.ellipsis,
                                    style: rowTextStyle,
                                  ),
                                ),
                                // The chevron is what actually marks this as
                                // tappable — colour alone reads as emphasis.
                                Icon(Icons.chevron_right,
                                    size: 16,
                                    color: theme.colorScheme.secondary),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }

              String? km(int? meters) =>
                  meters != null ? (meters / 1000).toStringAsFixed(1) : null;

              final kmThisYear = km(stats.distanceThisYearMeters);
              final kmAllTime = km(stats.totalDistanceMeters);

              final lastRun = stats.mostRecentRun;

              return Column(
                children: <Widget>[
                  Text("XLrun", style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      // The this-year pair is hidden entirely when there are no
                      // runs this year — showing "0 тази година" next to a hidden
                      // "км тази година" reads as inconsistent.
                      if (stats.runsThisYear > 0) ...<Widget>[
                        Expanded(
                            child: stat(stats.runsThisYear.toString(),
                                l10n.profile_page_xl_this_year)),
                        if (kmThisYear != null)
                          Expanded(
                              child: stat(kmThisYear,
                                  l10n.profile_page_xl_km_this_year)),
                      ],
                      Expanded(
                          child: stat(stats.runsAllTime.toString(),
                              l10n.profile_page_xl_all_time)),
                      if (kmAllTime != null)
                        Expanded(
                            child: stat(
                                kmAllTime, l10n.profile_page_xl_km_all_time)),
                    ],
                  ),
                  // Splits the card into its two halves: the aggregate
                  // numbers above, the last run below.
                  if (lastRun != null) const Divider(height: 20),
                  if (lastRun != null)
                    metaRow(
                      Icons.terrain,
                      l10n.profile_page_xl_last_run,
                      linkText: (lastRun.location ?? "").isNotEmpty
                          ? "${lastRun.displayDate} · ${lastRun.location}"
                          : lastRun.displayDate,
                      onTap: () {
                        final tabHelper = Provider.of<TabNavigationHelper>(
                            context,
                            listen: false);
                        tabHelper.selectTab(AppTab.runs);
                        tabHelper.pushToTab(AppTab.runs, "/run-details",
                            arguments: lastRun);
                      },
                    ),
                ],
              );
            }),
          ),
          // The strip doubles as the "next event" teaser here: its header
          // carries the event's location and date, so no separate line is
          // needed above it.
          if (nextEvent != null && nextEvent.registrationLinks.isNotEmpty)
            XLRegistrationSection(
              links: nextEvent.registrationLinks,
              subtitle:
                  "${nextEvent.location}, ${dateFromat.format(nextEvent.date)}",
            ),
        ],
      ),
    );
  }

  Widget buildRunsChartCard(List<Run> runs) {
    return Card(
      child: SizedBox(
        height: 200,
        child: RunsChart(runs: runs.take(30).toList()),
      ),
    );
  }

  Widget buildRunsByRouteCard(List<Run> runs) {
    return Card(
      child: SizedBox(
        height: 200,
        child: RunsByRouteChart.withRuns(runs),
      ),
    );
  }

  Widget buildBestTimesCard(List<Run> runs) {
    return Card(
      child: SizedBox(
        height: 350,
        child: BestTimesByRouteChart.withRuns(runs),
      ),
    );
  }
}
