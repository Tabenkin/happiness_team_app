import 'package:auto_route/auto_route.dart';
import 'package:happiness_team_app/router/auth_guard.dart';
import 'package:happiness_team_app/router/happiness_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: AuthRoute.page),
        AutoRoute(page: ResetPasswordRoute.page),
        AutoRoute(
          page: HomeRoute.page,
          initial: true,
          guards: [AuthGuard()],
        ),
        AutoRoute(
          page: WelcomeRoute.page,
          guards: [AuthGuard()],
        ),
      ];
}
