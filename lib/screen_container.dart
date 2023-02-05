import 'package:flutter/material.dart';
import 'package:pertolo_control/app.dart';

class ScreenContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const ScreenContainer({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: App.primaryColor,
        body: Container(
            padding: padding ??
                EdgeInsets.symmetric(
                    horizontal: App.getPaddingHorizontal(context),
                    vertical: 50),
            child: child));
  }
}
