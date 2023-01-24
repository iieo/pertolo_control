import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pertolo_control/app.dart';
import 'package:pertolo_control/components/pertolo_button.dart';

class LoginScreen extends StatefulWidget {
  final Function toggleIsLogin;
  const LoginScreen({super.key, required this.toggleIsLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = '';
  String _password = '';

  final _formKey = GlobalKey<FormState>();

  void _login() async {
    final bool? isValid = _formKey.currentState?.validate();
    if (isValid!) {
      _formKey.currentState?.save();
      FocusScope.of(context).unfocus();
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
      } on FirebaseAuthException catch (e) {
        String text = 'Unknown error: ${e.code}';
        if (e.code == 'user-not-found') {
          text = "Benutzer nicht gefunden. Bitte gib eine andere E-Mail ein.";
        } else if (e.code == 'wrong-password') {
          text = "Falsches Password";
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(text)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            style: ThemeData.dark().textTheme.labelMedium,
            key: const ValueKey('email'),
            validator: (value) {
              if (value!.isEmpty || !value.contains('@')) {
                return 'Bitte gib eine gültige E-Mail ein.';
              }
              return null;
            },
            onSaved: (value) {
              _email = value!;
            },
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'E-Mail',
              labelStyle: ThemeData.dark().textTheme.labelMedium,
            ),
          ),
          TextFormField(
            style: ThemeData.dark().textTheme.labelMedium,
            key: const ValueKey('password'),
            validator: (value) {
              if (value!.isEmpty || value.length < 7) {
                return 'Bitte gib ein gültiges oder längeres Passwort ein.';
              }
              return null;
            },
            onSaved: (value) {
              _password = value!;
            },
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              labelText: 'Passwort',
              labelStyle: ThemeData.dark().textTheme.labelMedium,
            ),
          ),
          const SizedBox(
            height: 45,
          ),
          PertoloButton(onPressed: _login, text: "Anmelden"),
          const SizedBox(
            height: 20,
          ),
          TextButton(
            onPressed: () {
              widget.toggleIsLogin();
            },
            child: const Text('Noch keinen Account?'),
          ),
        ],
      ),
    );
  }
}
