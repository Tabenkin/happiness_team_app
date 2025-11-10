import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/widgets/Base/base_button.widget.dart';
import 'package:happiness_team_app/widgets/Base/base_text.widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

@RoutePage()
class WorkshopsScreen extends StatelessWidget {
  const WorkshopsScreen({
    super.key,
  });

  _viewWebsite() async {
    const url = "https://myhappiness.team/";

    await launchUrlString(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const BaseText('Workshops'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Divider(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    BaseText(
                      "Join an upcoming Happiness Team workshop!",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    BaseText(
                      "Celebrating your wins using this app is a good first step towards happiness. But we have so much more in store for you at Happiness Team! Happiness Team is a life-changing, intensive workshop and accountability team led by Tal Tsfany.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    BaseText(
                      "In the workshop, you will explore your passions, values, and inner emotional world. You will consciously select and pursue values that will enrich your life, heighten your self-esteem and increase your level of happiness. You’ll gain the confidence to know who you are and what you want out of life. And you’ll build the reasoning, planning, and motivation to commit to going after it.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    BaseText(
                      "We practice a philosophy that leads to deep and long-lasting happiness. We can help you figure out who you are and what you really want out of life.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    BaseText(
                      "We love that people serious about their lives, longing for a life of meaning, find their way to Happiness Team. Check out our upcoming virtual workshops!",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: SizedBox(
                width: double.infinity,
                child: BaseButton(
                  onPressed: _viewWebsite,
                  width: double.infinity,
                  child: const BaseText("View our Website"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
