import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:happiness_team_app/components/win_list/win_photo_gallery.widget.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/helpers/dialog.helpers.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/widgets/image_full_screen_wrapper.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
  final CarouselController _carouselController = CarouselController();

  _shareWin() async {
    final box = context.findRenderObject() as RenderBox?;

    await Share.share(
      "Check out my win from ${widget.win.formattedDate}!\n\n${widget.win.notes}\n\nI recorded this awesome win using the Happiness Team app. You should try it out. Here’s a link:\n\nhttps://sfbyw.app.link/SkTrc6ajZHb",
      subject: "Check out my win!",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );

    await FirebaseAnalytics.instance.logEvent(name: "share_win");
  }

  _viewPhotoGallery() {
    DialogHelper.showFadeInModal(
      context,
      child: WinPhotoGallery(win: widget.win),
    );
  }

  int _currentPhotoIndex = 0;

  void _nextPage() {
    _carouselController.nextPage(duration: const Duration(milliseconds: 150));
  }

  void _previousPage() {
    _carouselController.previousPage(
        duration: const Duration(milliseconds: 150));
  }

  @override
  void initState() {
    super.initState();
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.win.images.length == 1)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: Theme.of(context).borderRadius,
                        child: AspectRatio(
                          aspectRatio: 1.5,
                          child: ImageFullScreenWrapperWidget(
                            child: Image.network(
                              widget.win.image!.mediaHref,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                    ],
                  ),
                if (widget.win.images.length > 1)
                  Column(
                    children: [
                      Column(
                        children: [
                          CarouselSlider.builder(
                            carouselController: _carouselController,
                            itemCount: widget.win.images.length,
                            itemBuilder: (context, index, realIndex) {
                              return ClipRRect(
                                borderRadius: Theme.of(context).borderRadius,
                                child: AspectRatio(
                                  aspectRatio: 1.5,
                                  child: ImageFullScreenWrapperWidget(
                                    child: Image.network(
                                      widget.win.images[index].mediaHref,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                            options: CarouselOptions(
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentPhotoIndex = index;
                                });
                              },
                              pageSnapping: true,
                              enlargeCenterPage: widget.win.images.length > 1,
                              enableInfiniteScroll:
                                  widget.win.images.length > 1,
                              aspectRatio: 1.5,
                            ),
                          ),
                          if (widget.win.images.length > 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IgnorePointer(
                                  ignoring: _currentPhotoIndex == 0,
                                  child: AnimatedOpacity(
                                    opacity:
                                        _currentPhotoIndex == 0 ? 0.0 : 1.0,
                                    duration: const Duration(milliseconds: 150),
                                    child: IconButton(
                                      onPressed: _previousPage,
                                      icon: const Icon(
                                        Icons.chevron_left,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 4.0,
                                ),
                                Text(
                                  "${_currentPhotoIndex + 1} / ${widget.win.images.length} photos",
                                ),
                                const SizedBox(
                                  width: 4.0,
                                ),
                                IgnorePointer(
                                  ignoring: _currentPhotoIndex ==
                                      widget.win.images.length - 1,
                                  child: AnimatedOpacity(
                                    opacity: _currentPhotoIndex ==
                                            widget.win.images.length - 1
                                        ? 0.0
                                        : 1.0,
                                    duration: const Duration(milliseconds: 150),
                                    child: IconButton(
                                      onPressed: _nextPage,
                                      icon: const Icon(
                                        Icons.chevron_right,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
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
                    Row(
                      children: [
                        IconButton(
                          onPressed: widget.onEdit,
                          icon: const Icon(Icons.edit_note),
                        ),
                        IconButton(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          onPressed: _shareWin,
                          icon: Icon(
                            Platform.isIOS ? Icons.ios_share : Icons.share,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
