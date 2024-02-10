import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/router/happiness_router.gr.dart';
import 'package:happiness_team_app/screens/welcome/welcome_info.page.dart';
import 'package:happiness_team_app/screens/welcome/welcome_video.page.dart';

@RoutePage()
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0; // Add this line

  _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeIn,
    );
  }

  _navigateHome() {
    context.router.replace(const HomeRoute());
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var pages = [
      WelcomeInfoPage(
        onNextPage: _nextPage,
      ),
      WelcomeVideoPage(
        onNextPage: _navigateHome,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController, // Make sure to use the controller
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page; // Update the current page index
                  });
                },
                children: pages,
              ),
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the dots horizontally
              children: List<Widget>.generate(
                pages.length, // Change this to your actual number of pages
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 10,
                  width: _currentPage == index
                      ? 10
                      : 10, // Current page dot is larger
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? theme.dark
                        : theme.medium, // Active dot is darker
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
