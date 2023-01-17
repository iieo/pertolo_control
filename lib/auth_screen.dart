import 'package:flutter/material.dart';
import 'package:pertolo_control/ScreenContainer.dart';
import 'package:pertolo_control/login.dart';
import 'package:pertolo_control/register.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  void toggleIsLogin() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
        child: Center(
            child: Container(
      width: MediaQuery.of(context).size.width / 3,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: SafeArea(
                  child: isLogin
                      ? LoginScreen(toggleIsLogin: toggleIsLogin)
                      : SignupScreen(toggleIsLogin: toggleIsLogin))),
          TextButton(
            child: const Text("Infos zum löschen des Accounts"),
            onPressed: () {
              //create snackbar with text
              SnackBar snackBar = const SnackBar(
                  content: Text(
                      "Zum Account löschen bitte eine E-Mail an: achtbyte01@gmail.com"));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          )
        ],
      ),
    )));
  }
}
