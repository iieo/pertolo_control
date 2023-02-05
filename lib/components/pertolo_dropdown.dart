import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pertolo_control/app.dart';

class PertoloDropdown<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final T value;
  final Function onChanged;

  const PertoloDropdown(
      {super.key,
      required this.items,
      required this.value,
      required this.onChanged});

  @override
  State<PertoloDropdown> createState() => _PertoloDropdownState<T>();
}

class _PertoloDropdownState<T> extends State<PertoloDropdown> {
  @override
  Widget build(BuildContext context) {
    double width = App.getMaxWidth(context);
    double height = 60;
    return SizedBox(
        width: width,
        height: height,
        child: DropdownButton<T>(
            value: widget.value as T,
            style: ThemeData.dark().textTheme.button,
            dropdownColor: App.secondaryColor,
            items: widget.items as List<DropdownMenuItem<T>>,
            onChanged: (T? val) => widget.onChanged(val)));
  }
}
