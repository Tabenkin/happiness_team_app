import 'package:flutter/material.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/screens/home/grouped_wins_list_modal.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';

class GroupedWinsGrid extends StatelessWidget {
  final Map<String, Wins> groupedWins;
  final String Function(String)? labelGenerator;

  const GroupedWinsGrid({
    required this.groupedWins,
    this.labelGenerator,
    Key? key,
  }) : super(key: key);

  _showWins(BuildContext context, String label, Wins wins) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, // Make route background transparent
        pageBuilder: (context, animation, secondaryAnimation) {
          final screenHeight = MediaQuery.of(context).size.height;
          return Container(
            alignment: Alignment
                .bottomCenter, // Align the container to the bottom of the screen
            child: SizedBox(
              height: screenHeight *
                  1, // Set the height to 90% of the screen height
              child: GroupedWinsListModal(
                labelBackgroundColor: Theme.of(context).colorScheme.primary,
                label: label,
                wins: wins,
              ),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            // Directly return the Card widget.
            var labelKey = groupedWins.keys.elementAt(index);
            var label = labelKey;

            if (labelGenerator != null) {
              label = labelGenerator!(label);
            }

            return Hero(
              tag: label,
              child: Card(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () => _showWins(context, label, groupedWins[labelKey]!),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyText(
                            label, // Displaying the year from groupedWins.
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium, // Applying text style.
                          ),
                          MyText(
                            "(${groupedWins[labelKey]!.length})",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: groupedWins.keys
              .length, // Number of items in the grid is determined by the number of keys in groupedWins.
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.5),
      ),
    );
  }
}
