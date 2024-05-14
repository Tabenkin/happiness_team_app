import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

@RoutePage()
class WorkshopsScreen extends StatelessWidget {
  const WorkshopsScreen({
    Key? key,
  }) : super(key: key);

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
        title: const Text('Workshops'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Divider(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              "Join an upcoming Happiness Team workshop!",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: 32.0,
            ),
            SizedBox(
              width: double.infinity,
              child: MyButton(
                onTap: _viewWebsite,
                child: const Text("View our Website"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
