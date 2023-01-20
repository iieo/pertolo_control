import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pertolo_control/auth_screen.dart';
import 'package:pertolo_control/create_screen.dart';
import 'package:pertolo_control/edit_screen.dart';
import 'package:pertolo_control/gorouter_refresh_stream.dart';
import 'package:pertolo_control/home_screen.dart';

class App extends StatelessWidget {
  App({super.key});

  static const Color primaryColor = Color(0xFF060e33);
  static const int white = 200;
  static const Color whiteColor = Color.fromARGB(255, 228, 226, 223);
  static const Color secondaryColor = Color(0xFFcb134e);
  static const String name = 'Pertol Control';
  static const String version = '1.0.0';
  static const String buildNumber = '1';
  static const Duration animationDuration = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: name,
      theme: _themeData,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp.router(
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
            title: App.name,
            theme: _themeData);
      },
    );
  }

  final GoRouter _router = GoRouter(
    redirect: (context, state) {
      final bool loggedIn = FirebaseAuth.instance.currentUser != null;
      const loginLocation = "/login";
      final loggingIn = state.subloc == loginLocation;

      const homeLocation = "/";

      if (!loggedIn) {
        return loginLocation;
      }

      if (loggingIn) {
        state.queryParams['from'];
        return state.queryParams['from'] ?? homeLocation;
      }

      return null;
    },
    refreshListenable:
        GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            name: 'login',
            path: 'login',
            builder: (BuildContext context, GoRouterState state) {
              return const AuthScreen();
            },
          ),
          GoRoute(
            name: 'logout',
            path: 'logout',
            builder: (BuildContext context, GoRouterState state) {
              FirebaseAuth.instance.signOut();
              return const NotFoundScreen();
            },
          ),
          GoRoute(
            name: 'create',
            path: 'create',
            builder: (BuildContext context, GoRouterState state) {
              return const CreateScreen();
            },
          ),
          GoRoute(
            name: 'edit',
            path: 'edit',
            builder: (BuildContext context, GoRouterState state) {
              return const EditScreen();
            },
          ),
        ],
      ),
    ],
  );

  final ThemeData _themeData = ThemeData(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primarySwatch: const MaterialColor(0xFFFEFAE0, {
        50: Color(0xfff2f2f2),
        100: Color(0xffe6e6e6),
        200: Color(0xffcccccc),
        300: Color(0xffb3b3b3),
        400: Color(0xff999999),
        500: Color(0xff808080),
        600: Color(0xff666666),
        700: Color(0xff4d4d4d),
        800: Color(0xff333333),
        900: Color(0xff1a1a1a)
      }),
      primaryColor: primaryColor,
      textTheme: const TextTheme(
        button: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none,
          color: App.whiteColor,
        ),
        labelMedium: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none,
          color: App.whiteColor,
        ),
        subtitle1: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none,
          color: Color.fromARGB(255, 150, 150, 150),
        ),
      ));
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          '404 Not Found',
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
    );
  }
}
