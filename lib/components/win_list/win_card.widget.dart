import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:share_plus/share_plus.dart';

class WinCard extends StatelessWidget {
  final Win win;
  final Function() onEdit;

  const WinCard({
    required this.win,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  _shareWin() {
    Share.share("Check out my win! ${win.notes}");
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (ctx) {
              win.delete();
            },
            backgroundColor: Theme.of(context).colorScheme.error,
            icon: Icons.delete,
            label: "Delete",
          ),
        ],
      ),
      child: Card(
        surfaceTintColor: theme.colorScheme.background,
        color: theme.colorScheme.background,
        margin: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            // border: Border.all(
            //   color: Theme.of(context).colorScheme.primary,
            //   width: 1.0,
            // ),
            color: theme.lightBlue.withOpacity(0.4),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0),
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    win.notes,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyText(
                        win.formattedDate,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          height: 1.0,
                        ),
                      ),
                      IconButton(
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        onPressed: _shareWin,
                        icon: const Icon(
                          Icons.ios_share,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
