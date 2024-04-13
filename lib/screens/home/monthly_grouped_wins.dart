import 'package:flutter/material.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/helpers/functions.helpers.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/screens/home/grouped_wins_grid.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
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
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 16.0,
          ),
        ),
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
          child: Container(
            color: Theme.of(context).colorScheme.background,
            padding:
                const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  year,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const Divider(),
              ],
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
        ),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 32.0,
          ),
        ),
      ],
    );
  }
}
