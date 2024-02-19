import 'package:flutter/material.dart';
import 'package:happiness_team_app/components/win_list/win_card.widget.dart';
import 'package:happiness_team_app/helpers/functions.helpers.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/providers/wins.provider.dart';
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
                          Text(
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
                // child: Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Align(
                //     alignment: Alignment.center,
                //     child: Padding(
                //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //       child: PhysicalModel(
                //         color: Theme.of(context).colorScheme.onPrimary,
                //         borderRadius: BorderRadius.circular(20.0),
                //         elevation: 0.0,
                //         child: Container(
                //           width: double.infinity,
                //           decoration: BoxDecoration(
                //             border: Border.all(
                //                 color: Theme.of(context).colorScheme.primary),
                //             borderRadius: BorderRadius.circular(20.0),
                //             color: Theme.of(context)
                //                 .colorScheme
                //                 .onPrimary
                //                 .withOpacity(0.2),
                //           ),
                //           padding: const EdgeInsets.symmetric(
                //               vertical: 16.0, horizontal: 16.0),
                //           child: Column(
                //             children: [
                //               Text(
                //                 entry.key,
                //                 textAlign: TextAlign.center,
                //                 style: Theme.of(context)
                //                     .textTheme
                //                     .bodyLarge!
                //                     .copyWith(
                //                         color: Theme.of(context)
                //                             .colorScheme
                //                             .secondary),
                //               ),
                //               const SizedBox(
                //                 height: 4.0,
                //               ),
                //               Text(
                //                 "(${entry.value.length} wins)",
                //                 style: Theme.of(context).textTheme.bodyMedium,
                //               )
                //             ],
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
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
