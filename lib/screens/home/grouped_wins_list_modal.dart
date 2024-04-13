import 'package:flutter/material.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/providers/wins.provider.dart';
import 'package:happiness_team_app/screens/home/grouped_wins_list.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:provider/provider.dart';

class GroupedWinsListModal extends StatelessWidget {
  final Color labelBackgroundColor;
  final String label;
  final String dateKey;
  final Wins wins;

  const GroupedWinsListModal({
    required this.labelBackgroundColor,
    required this.label,
    required this.dateKey,
    required this.wins,
    Key? key,
  }) : super(key: key);

  _editWin(BuildContext context, Win win) {
    // Here is where I'll put the edit win form
    WinsProvider.showWinForm(context, win);
  }

  @override
  Widget build(BuildContext context) {
    // Group wins by year

    return ValueListenableBuilder(
        valueListenable: Provider.of<WinsProvider>(context, listen: false).wins,
        builder: (context, allWins, _) {
          var filteredWins = allWins.where((win) {
            // get win.date formatted for YEAR like 2024
            // Generate the strings for year, year-month, and year-month-day from win.date
            var winYear = win.date.year.toString();
            var winYearMonth =
                '${win.date.year}-${win.date.month.toString().padLeft(2, '0')}';
            var winYearMonthDay =
                '${win.date.year}-${win.date.month.toString().padLeft(2, '0')}-${win.date.day.toString().padLeft(2, '0')}';

            // Check if the dateKey matches any of the above formats
            return [winYear, winYearMonth, winYearMonthDay].contains(dateKey);
          }).toList();

          Map<String, Wins> groupedWins =
              WinsProvider.groupWinsByYearMonthDay(filteredWins);

          return Scaffold(
            body: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  // Here is where I'll put some sort of header in a hero option
                  Container(
                    color: labelBackgroundColor,
                    child: SafeArea(
                      child: SizedBox(
                        height: 100,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Hero(
                                tag: dateKey,
                                child: MyText(
                                  label,
                                  style:
                                      Theme.of(context).textTheme.titleMedium!,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(
                                  Icons.close,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 16.0),
                        ),
                        GroupedWinsList(
                          groupedWins: groupedWins,
                          onEditWin: (win) => _editWin(context, win),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
