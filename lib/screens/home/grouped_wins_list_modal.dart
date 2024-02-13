import 'package:flutter/material.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/providers/wins.provider.dart';
import 'package:happiness_team_app/screens/home/grouped_wins_list.widget.dart';

class GroupedWinsListModal extends StatelessWidget {
  final Color labelBackgroundColor;
  final String label;
  final Wins wins;

  const GroupedWinsListModal({
    required this.labelBackgroundColor,
    required this.label,
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
    Map<String, Wins> groupedWins = WinsProvider.groupWinsByYearMonthDay(wins);

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
                          tag: label,
                          child: Text(
                            label,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: () {
                            print("Is this getting called?");
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.close,
                              color: Theme.of(context).colorScheme.onPrimary),
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
                  // const SliverToBoxAdapter(
                  //   child: SizedBox(height: 16.0),
                  // ),
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
  }
}
