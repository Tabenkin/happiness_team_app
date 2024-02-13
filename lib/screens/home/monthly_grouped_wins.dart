import 'package:flutter/material.dart';
import 'package:happiness_team_app/helpers/functions.helpers.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/screens/home/grouped_wins_grid.dart';
import 'package:sliver_tools/sliver_tools.dart';

class MonthlyGroupedWins extends StatefulWidget {
  final Map<String, List<String>> yearMonthMap;
  final Map<String, Wins> yearMonthWins;

  const MonthlyGroupedWins({
    required this.yearMonthMap,
    required this.yearMonthWins,
    Key? key,
  }) : super(key: key);

  @override
  State<MonthlyGroupedWins> createState() => _MonthlyGroupedWinsState();
}

class _MonthlyGroupedWinsState extends State<MonthlyGroupedWins> {
  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: false,
      children: [
        for (var year in widget.yearMonthMap.keys) _buildYearGrid(year)
      ],
    );
  }

  Widget _buildYearGrid(String year) {
    // Create a new map from yearMonthWins for the given year.

    var yearMonthWinKeys = widget.yearMonthWins.keys
        .where((element) => element.contains("$year-"))
        .toList();

    Map<String, Wins> newYearMonthWins = {};

    for (var yearMonth in yearMonthWinKeys) {
      newYearMonthWins[yearMonth] = widget.yearMonthWins[yearMonth] ?? [];
    }

    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: PhysicalModel(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(20.0),
                elevation: 0.0,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(20.0),
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16.0),
                  child: Text(
                    year,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ),
            ),
          ),
        ),
        GroupedWinsGrid(
          groupedWins: newYearMonthWins,
          labelGenerator: (label) {
            // The label is a year mont like 2024-02
            // Convrt that to the month name

            return convertToMonthName(label);
          },
        )
      ],
    );
  }
}
