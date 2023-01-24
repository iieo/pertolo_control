import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pertolo_control/app.dart';
import 'dart:math';

import 'package:pertolo_control/components/pertolo_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool alreadySent = false;
  void _sendAgain() {
    if (!alreadySent) {
      FirebaseAuth.instance.currentUser!.sendEmailVerification();
    }
    setState(() {
      alreadySent = true;
    });
  }

  void _navigateToCreateScreen(BuildContext context) {
    GoRouter.of(context).go('/create');
  }

  void _navigateToEditScreen(BuildContext context) {
    GoRouter.of(context).go('/edit');
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
  }

  Future<bool> _userEmailVerified({int retries = 3}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await Future.delayed(const Duration(seconds: 1));
      if (retries > 0) {
        return _userEmailVerified(retries: retries - 1);
      } else {
        return false;
      }
    }
    await user.reload();
    return user.emailVerified;
  }

  void _reloadInFewSeconds(int seconds) {
    Future.delayed(Duration(seconds: seconds), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: App.primaryColor,
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // create button, edit button, logout button
          FutureBuilder(
            builder: ((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null || snapshot.hasError) {
                  _reloadInFewSeconds(3);
                  return const Text("No internet connection",
                      style: TextStyle(color: App.secondaryColor));
                }
                if (snapshot.data == true) {
                  return Column(
                    children: [
                      PertoloButton(
                          onPressed: () => _navigateToCreateScreen(context),
                          text: "Create"),
                      const SizedBox(height: 20),
                      PertoloButton(
                          onPressed: () => _navigateToEditScreen(context),
                          text: "Edit"),
                      const SizedBox(height: 20),
                      PertoloButton(onPressed: _logout, text: "Ausloggen"),
                    ],
                  );
                } else {
                  _reloadInFewSeconds(1);
                  return Column(
                    children: [
                      Text("Bitte verifiziere deine E-Mail-Adresse",
                          style: ThemeData.dark().textTheme.button),
                      const SizedBox(height: 20),
                      PertoloButton(
                          onPressed: _sendAgain, text: "Erneut senden"),
                      const SizedBox(height: 20),
                      PertoloButton(onPressed: _logout, text: "Ausloggen"),
                    ],
                  );
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
            future: _userEmailVerified(),
          ),
        ],
      )),
    );
  }
}
