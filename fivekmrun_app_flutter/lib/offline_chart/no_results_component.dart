import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoResultsComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          Text(
              AppLocalizations.of(context)!
                  .no_results_component_no_suitable_runs,
              style: Theme.of(context).textTheme.titleSmall),
          Padding(
            padding: const EdgeInsets.only(
                left: 36.0, top: 36.0, right: 36.0, bottom: 18.0),
            child: Text(AppLocalizations.of(context)!
                .no_results_component_participation_requirements),
          ),
          Column(
            children: [
              Text(
                  AppLocalizations.of(context)!
                      .no_results_component_requirements,
                  textAlign: TextAlign.left),
            ],
          ),
        ],
      ),
    );
  }
}
