import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/providers/app.provider.dart';
import 'package:happiness_team_app/providers/auth_state.provider.dart';
import 'package:happiness_team_app/providers/user.provider.dart';
import 'package:happiness_team_app/providers/wins.provider.dart';
import 'package:happiness_team_app/router/auth_state_listener.dart';
import 'package:happiness_team_app/router/happiness_router.dart';
import 'package:happiness_team_app/router/happiness_router.gr.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding
      .ensureInitialized(); // Ensure plugin services are initialized
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(); // Initialize Firebase

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = AppRouter();

  late WinsProvider _winsProvider;
  late UserProvider _userProvider;
  late AuthStateProvider _authProvider;
  late AppProvider _appProvider;

  @override
  void initState() {
    _winsProvider = WinsProvider();
    _userProvider = UserProvider();
    _authProvider = AuthStateProvider();
    _appProvider = AppProvider(
      userProvider: _userProvider,
      winsProvider: _winsProvider,
    );

    _authProvider.initializeListeners();

    FirebaseMessaging.onBackgroundMessage((message) async {
      _handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    _checkInitialMessages();

    super.initState();
  }

  _checkInitialMessages() async {
    var initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  _handleMessage(RemoteMessage message) {
    if (message.data['event'] == null) return;

    if (message.data['event'] == 'randomWinReminder') {
      Future.delayed(const Duration(milliseconds: 100), () {
        _appRouter.navigate(const HomeRoute());
        _winsProvider.triggerRandomWin();
      });
    }

    if (message.data['event'] == 'addWinReminder') {
      Future.delayed(const Duration(milliseconds: 100), () {
        _appRouter.navigate(const HomeRoute());
        _winsProvider.triggerAddWin();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _winsProvider),
          ChangeNotifierProvider.value(value: _userProvider),
          ChangeNotifierProvider.value(value: _authProvider),
          ChangeNotifierProvider.value(value: _appProvider),
        ],
        builder: (context, child) {
          return FutureBuilder(
              future: _appProvider.onAppStart(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const MaterialApp(
                    home: Scaffold(
                      body: Center(
                        child: SizedBox(),
                      ),
                    ),
                  );
                }

                FlutterNativeSplash.remove();

                return OKToast(
                  child: MaterialApp.router(
                    title: 'The Happiness Team',
                    theme: happinessTheme,
                    routerConfig: _appRouter.config(
                      reevaluateListenable: _authProvider,
                    ),
                  ),
                );
              });
        });
  }
}
