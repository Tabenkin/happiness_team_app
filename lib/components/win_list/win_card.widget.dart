import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/widgets/image_full_screen_wrapper.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:share_plus/share_plus.dart';

class WinCard extends StatefulWidget {
  final Win win;
  final Function() onEdit;

  const WinCard({
    required this.win,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  State<WinCard> createState() => _WinCardState();
}

class _WinCardState extends State<WinCard> {
  _shareWin() async {
    final box = context.findRenderObject() as RenderBox?;

    await Share.share(
      "Check out my win from ${widget.win.formattedDate}!\n\n${widget.win.notes}\n\nI recorded this awesome win using the Happiness Team app.\n\nhttps://sfbyw.app.link/SkTrc6ajZHb",
      subject: "Check out my win!",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
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
              widget.win.delete();
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
            color: theme.lightBlue.withOpacity(0.4),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0),
            onTap: widget.onEdit,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.win.image != null)
                    Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1.5,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: Theme.of(context).borderRadius,
                            ),
                            child: ClipRRect(
                              borderRadius: Theme.of(context).borderRadius,
                              child: ImageFullScreenWrapperWidget(
                                child: Image.network(
                                  widget.win.image!.mediaHref,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                      ],
                    ),
                  MyText(
                    widget.win.notes,
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
                        widget.win.formattedDate,
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
