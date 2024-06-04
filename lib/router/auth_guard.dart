import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:happiness_team_app/router/happiness_router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    var isAuthenticated = FirebaseAuth.instance.currentUser != null;

    if (isAuthenticated) {
      resolver.next();
    } else {
      resolver.redirect(const AuthRoute());
    }
  }
}
