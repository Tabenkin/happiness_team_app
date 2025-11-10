import 'package:flutter/material.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/models/media_object.model.dart';
import 'package:happiness_team_app/widgets/Base/base_video_player.widget.dart';
import 'package:happiness_team_app/widgets/image_full_screen_wrapper.widget.dart';

class WinMediaPreview extends StatefulWidget {
  final MediaObject mediaObject;

  const WinMediaPreview({
    required this.mediaObject,
    Key? key,
  }) : super(key: key);

  @override
  State<WinMediaPreview> createState() => _WinMediaPreviewState();
}

class _WinMediaPreviewState extends State<WinMediaPreview> {
  bool get _isImage {
    return widget.mediaObject.contentType.contains("video") != true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isImage) {
      return ClipRRect(
        borderRadius: Theme.of(context).borderRadius,
        child: AspectRatio(
          aspectRatio: 1.5,
          child: ImageFullScreenWrapperWidget(
            child: Image.network(
              widget.mediaObject.mediaHref,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: Theme.of(context).borderRadius,
      child: AspectRatio(
        aspectRatio: 1.5,
        child: BaseVideoPlayer(
          mediaObject: widget.mediaObject,
        ),
      ),
    );
  }
}
