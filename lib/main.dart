import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:happiness_team_app/firebase_options.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/providers/app.provider.dart';
import 'package:happiness_team_app/providers/auth_state.provider.dart';
import 'package:happiness_team_app/providers/user.provider.dart';
import 'package:happiness_team_app/providers/wins.provider.dart';
import 'package:happiness_team_app/router/happiness_router.dart';
import 'package:happiness_team_app/router/happiness_router.gr.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding
      .ensureInitialized(); // Ensure plugin services are initialized
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase

  try {
    await FlutterBranchSdk.init();
  } catch (error) {}

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
  
  RemoteMessage? _pendingMessage;

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

    FlutterBranchSdk.listSession().listen((data) {
      print("Branch link clicked. $data");

      if (data.containsKey("+clicked_branch_link") &&
          data["+clicked_branch_link"] == true) {
        var event = data["event"];

        if (event == null) return;

        if (event == "addWin") {
          _openAddWin();
        }
      }
    }, onError: (error) {
      print('listSession error: ${error.toString()}');
    });

    super.initState();
  }

  _checkInitialMessages() async {
    var initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      // Store the message to handle it after app initialization
      _pendingMessage = initialMessage;
    }
  }

  _handleMessage(RemoteMessage message) {
    if (message.data['event'] == null) return;

    if (message.data['event'] == 'randomWinReminder' &&
        message.data['winId'] != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _appRouter.navigate(const HomeRoute());
        _winsProvider.triggerRandomWin(message.data['winId']);
      });
    }

    if (message.data['event'] == 'addWinReminder') {
      _openAddWin();
    }
  }

  _openAddWin() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _appRouter.navigate(const HomeRoute());
      _winsProvider.triggerAddWin();
    });
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
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  body: Center(
                    child: SizedBox(),
                  ),
                ),
              );
            }

            FlutterNativeSplash.remove();
            
            // Handle pending message after app initialization
            if (_pendingMessage != null) {
              final message = _pendingMessage;
              _pendingMessage = null;
              Future.microtask(() => _handleMessage(message!));
            }

            return OKToast(
              child: MaterialApp.router(
                title: 'The Happiness Team',
                theme: happinessTheme,
                debugShowCheckedModeBanner: false,
                routerConfig: _appRouter.config(
                  reevaluateListenable: _authProvider,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
