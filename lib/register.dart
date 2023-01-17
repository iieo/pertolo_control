import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pertolo_control/main.dart';

class SignupScreen extends StatefulWidget {
  final Function toggleIsLogin;
  const SignupScreen({super.key, required this.toggleIsLogin});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _username = '';
  String _email = '';
  String _password = '';
  bool _isAccepted = false;
  final _formKey = GlobalKey<FormState>();

  void _registerAndSaveData() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid!) {
      _formKey.currentState?.save();
      FocusScope.of(context).unfocus();
      try {
        UserCredential result = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);
        await result.user!.updateDisplayName(_username);
        await result.user!.sendEmailVerification();
        await result.user!.reload();
      } on FirebaseAuthException catch (e) {
        String text = 'Unknown error: ${e.code}';
        if (e.code == 'user-not-found') {
          text = "Benutzer nicht gefunden. Bitte gib eine andere E-Mail ein.";
        } else if (e.code == 'email-already-in-use') {
          text = "E-Mail wird bereits verwendet";
        } else if (e.code == 'wrong-password') {
          text = "Passwörter stimmen nicht überein";
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
            key: const ValueKey('username'),
            validator: (value) {
              if (value!.isEmpty || value.length < 4) {
                return 'Bitte gib einen Benutzernamen mit mindestens 4 Zeichen ein.';
              }
              return null;
            },
            onSaved: (value) {
              _username = value!;
            },
            decoration: const InputDecoration(
                labelText: 'Benutzername',
                labelStyle: TextStyle(color: App.secondaryColor)),
          ),
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
                return 'Bitte gib ein Passwort mit mindestens 7 Zeichen ein.';
              }
              return null;
            },
            onSaved: (value) {
              _password = value!;
            },
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Passwort',
              labelStyle: TextStyle(color: App.secondaryColor),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: _registerAndSaveData,
            child: const Text('Registrieren'),
          ),
          TextButton(
            onPressed: () {
              widget.toggleIsLogin();
            },
            child: const Text('Zurück zum Login'),
          ),
        ],
      ),
    );
  }
}
