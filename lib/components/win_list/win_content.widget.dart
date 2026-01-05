import 'package:flutter/material.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/widgets/image_full_screen_wrapper.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';

class WinContent extends StatefulWidget {
  final Win win;

  const WinContent({
    required this.win,
    super.key,
  });

  @override
  State<WinContent> createState() => _WinContentState();
}

class _WinContentState extends State<WinContent> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.win.image != null)
              Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1.8,
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
            Expanded(
              child: SingleChildScrollView(
                child: MyText(
                  widget.win.notes,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
                ),
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyText(
                  widget.win.formattedDate,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
