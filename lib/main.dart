import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pertolo_control/create_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:pertolo_control/gorouter_refresh_stream.dart';
import 'package:pertolo_control/home_screen.dart';
import 'package:pertolo_control/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  runApp(App());
}

class App extends StatelessWidget {
  App({super.key});

  static const Color primaryColor = Colors.green;
  static const Color secondaryColor = Color.fromARGB(255, 254, 250, 224);
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
  );
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
