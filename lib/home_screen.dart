import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pertolo_control/main.dart';
import 'dart:math';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToCreateScreen(BuildContext context) {
    GoRouter.of(context).go('/create');
  }

  void _navigateToEditScreen(BuildContext context) {
    GoRouter.of(context).go('/edit');
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    double width = max(200, MediaQuery.of(context).size.width - 100);
    double height = 60;
    return Container(
      color: App.primaryColor,
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // create button, edit button, logout button
          SizedBox(
              height: height,
              width: width,
              child: ElevatedButton(
                  onPressed: () => _navigateToCreateScreen(context),
                  child: const Text('Create',
                      style: TextStyle(color: App.primaryColor)))),
          const SizedBox(height: 20),
          SizedBox(
              height: height,
              width: width,
              child: ElevatedButton(
                  onPressed: () => _navigateToEditScreen(context),
                  child: const Text('Edit',
                      style: TextStyle(color: App.primaryColor)))),
          const SizedBox(height: 20),
          SizedBox(
              height: height,
              width: width,
              child: ElevatedButton(
                  onPressed: () => _logout(),
                  child: const Text('Logout',
                      style: TextStyle(color: App.primaryColor)))),
        ],
      )),
    );
  }
}
