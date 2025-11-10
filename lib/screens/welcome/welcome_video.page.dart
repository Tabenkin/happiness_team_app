import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/widgets/Base/base_button.widget.dart';
import 'package:happiness_team_app/widgets/Base/base_text.widget.dart';
import 'package:video_player/video_player.dart';

class WelcomeVideoPage extends StatefulWidget {
  final void Function() onNextPage;

  const WelcomeVideoPage({
    required this.onNextPage,
    super.key,
  });

  @override
  State<WelcomeVideoPage> createState() => _WelcomeVideoPageState();
}

class _WelcomeVideoPageState extends State<WelcomeVideoPage> {
  late FlickManager _flickManager;

  @override
  void initState() {
    var welcomeVideoHref =
        FirebaseRemoteConfig.instance.getString('welcome_video_href');
    var uri = Uri.parse(welcomeVideoHref);

    _flickManager = FlickManager(
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: FlickVideoPlayer(
                  flickManager: _flickManager,
                ),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            SizedBox(
              width: double.infinity,
              child: BaseButton(
                width: double.infinity,
                onPressed: widget.onNextPage,
                child: const BaseText("Get Started"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
