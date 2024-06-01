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

  _showWins(BuildContext context, String label, String dateKey, Wins wins) {
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
                labelBackgroundColor: const Color(0xFFE6E6FA),
                label: label,
                dateKey: dateKey,
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

  bool _hasImages(Wins wins) {
    for (var win in wins) {
      if (win.images.isNotEmpty) {
        return true;
      }
    }

    return false;
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
              tag: labelKey,
              child: Card(
                surfaceTintColor: Theme.of(context).colorScheme.background,
                color: Theme.of(context).colorScheme.background,
                child: Container(
                  decoration: BoxDecoration(
                    // color: Theme.of(context).colorScheme.secondary,
                    color: const Color(0xFFE6E6FA),
                    borderRadius: BorderRadius.circular(8.0),
                    // border: Border.all(
                    //   color: Theme.of(context).colorScheme.secondary,
                    // ),
                  ),
                  child: Stack(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(8.0),
                        onTap: () => _showWins(
                          context,
                          label,
                          labelKey,
                          groupedWins[labelKey]!,
                        ),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyText(
                                  label, // Displaying the year from groupedWins.
                                  style:
                                      Theme.of(context).textTheme.titleMedium!,
                                  maxTextScale: 1.0,
                                ),
                                MyText(
                                  "(${groupedWins[labelKey]!.length} wins)",
                                  style: Theme.of(context).textTheme.bodyLarge!,
                                  maxTextScale: 1.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_hasImages(groupedWins[labelKey]!) == true)
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(
                            Icons.photo_library,
                            size: 18.0,
                          ),
                        )
                    ],
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
