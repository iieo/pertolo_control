import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pertolo_control/main.dart';

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
        children: [
          TextFormField(
            style: const TextStyle(color: App.secondaryColor),
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
            decoration: const InputDecoration(
              labelText: 'E-Mail',
              labelStyle: TextStyle(color: App.secondaryColor),
            ),
          ),
          TextFormField(
            style: const TextStyle(color: App.secondaryColor),
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
            decoration: const InputDecoration(
              labelText: 'Passwort',
              labelStyle: TextStyle(color: App.secondaryColor),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: _login,
            child: const Text('Login'),
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
