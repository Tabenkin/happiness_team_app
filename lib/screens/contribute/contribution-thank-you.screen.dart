import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/router/happiness_router.gr.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';

@RoutePage()
class ContributionThankYouScreen extends StatelessWidget {
  const ContributionThankYouScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.volunteer_activism,
              size: 100,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(
              height: 24.0,
            ),
            Text(
              "Thank you for your contribution!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: 24.0,
            ),
            MyButton(
              child: const Text("Back to Home"),
              onTap: () {
                AutoRouter.of(context).replace(const HomeRoute());
              },
            ),
          ],
        ),
      ),
    );
  }
}
