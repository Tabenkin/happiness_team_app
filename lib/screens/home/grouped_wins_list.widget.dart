import 'package:flutter/material.dart';
import 'package:happiness_team_app/components/win_list/win_card.widget.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:sliver_tools/sliver_tools.dart';

class GroupedWinsList extends StatelessWidget {
  final Map<String, Wins> groupedWins;
  final Function(Win) onEditWin;

  const GroupedWinsList({
    required this.groupedWins,
    required this.onEditWin,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        for (var entry in groupedWins.entries)
          MultiSliver(
            pushPinnedChildren: true,
            children: [
              SliverPinnedHeader(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                            entry.key,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: WinCard(
                        win: entry.value[index],
                        onEdit: () => onEditWin(entry.value[index]),
                      ),
                    ),
                    childCount: entry.value.length,
                  ),
                ),
              ),
            ],
          )
      ],
    );
  }
}
