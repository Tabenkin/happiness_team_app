import 'package:flutter/material.dart';
import 'package:happiness_team_app/components/win_list/win_card.widget.dart';
import 'package:happiness_team_app/helpers/functions.helpers.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/providers/wins.provider.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:sliver_tools/sliver_tools.dart';

class GroupedWinsList extends StatefulWidget {
  final Map<String, Wins> groupedWins;
  final Function(Win) onEditWin;

  const GroupedWinsList({
    required this.groupedWins,
    required this.onEditWin,
    Key? key,
  }) : super(key: key);

  @override
  State<GroupedWinsList> createState() => _GroupedWinsListState();
}

class _GroupedWinsListState extends State<GroupedWinsList> {
  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        for (var entry in widget.groupedWins.entries)
          MultiSliver(
            pushPinnedChildren: true,
            children: [
              SliverPinnedHeader(
                child: Container(
                  color: Theme.of(context).colorScheme.background,
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          MyText(
                            convertDateStringToNiceFormat(entry.key),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(
                            width: 4.0,
                          ),
                        ],
                      ),
                      const Divider(),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  left: 16.0,
                  right: 16,
                  bottom: 32,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: WinCard(
                        win: entry.value[index],
                        onEdit: () => widget.onEditWin(entry.value[index]),
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
