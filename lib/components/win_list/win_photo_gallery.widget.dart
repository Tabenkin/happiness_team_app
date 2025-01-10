import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class WinPhotoGallery extends StatefulWidget {
  final Win win;

  const WinPhotoGallery({
    required this.win,
    Key? key,
  }) : super(key: key);

  @override
  State<WinPhotoGallery> createState() => _WinPhotoGalleryState();
}

class _WinPhotoGalleryState extends State<WinPhotoGallery> {
  var _currentPhotoIndex = 0;

  final CarouselController _carouselController = CarouselController();

  void _nextPage() {
    _carouselController.nextPage(duration: const Duration(milliseconds: 150));
  }

  void _previousPage() {
    _carouselController.previousPage(
        duration: const Duration(milliseconds: 150));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                      child: Image.network(
                        widget.win.images[index].mediaHref,
                        fit: BoxFit.cover,
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
                  enableInfiniteScroll: widget.win.images.length > 1,
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
                        opacity: _currentPhotoIndex == 0 ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: IconButton(
                          color: Theme.of(context).colorScheme.onPrimary,
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
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    IgnorePointer(
                      ignoring:
                          _currentPhotoIndex == widget.win.images.length - 1,
                      child: AnimatedOpacity(
                        opacity:
                            _currentPhotoIndex == widget.win.images.length - 1
                                ? 0.0
                                : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: IconButton(
                          color: Theme.of(context).colorScheme.onPrimary,
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
    );
  }
}
