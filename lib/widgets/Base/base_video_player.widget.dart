import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/models/media_object.model.dart';
import 'package:video_player/video_player.dart';

class BaseVideoPlayer extends StatefulWidget {
  final MediaObject mediaObject;

  const BaseVideoPlayer({
    required this.mediaObject,
    Key? key,
  }) : super(key: key);

  @override
  State<BaseVideoPlayer> createState() => _BaseVideoPlayerState();
}

class _BaseVideoPlayerState extends State<BaseVideoPlayer> {
  late FlickManager _flickManager;

  @override
  void initState() {
    var uri = Uri.parse(widget.mediaObject.mediaHref);
    _flickManager = FlickManager(
      autoPlay: false,
      videoPlayerController: VideoPlayerController.networkUrl(uri),
    );
    super.initState();
  }

  @override
  void dispose() {
    _flickManager.flickControlManager?.pause();
    _flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FlickVideoPlayer(
        flickManager: _flickManager,
      ),
    );
  }
}
