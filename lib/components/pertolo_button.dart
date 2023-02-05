import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pertolo_control/app.dart';

class PertoloButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  const PertoloButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    double width = App.getMaxWidth(context);
    double height = 60;
    return SizedBox(
        height: height,
        width: width,
        child: ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: App.secondaryColor),
            onPressed: () => onPressed(),
            child: Text(text, style: ThemeData.dark().textTheme.button)));
  }
}
