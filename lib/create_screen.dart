import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pertolo_control/components/pertolo_button.dart';
import 'package:pertolo_control/components/pertolo_dropdown.dart';
import 'package:pertolo_control/screen_container.dart';
import 'package:pertolo_control/app.dart';
import 'package:pertolo_control/pertolo_item.dart';

class CreateScreen extends StatefulWidget {
  final PertoloItem? pertoloItem;
  const CreateScreen({super.key, this.pertoloItem});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  String content = "";
  String category = "normal";
  ItemType type = ItemType.task;

  @override
  void initState() {
    if (_pertoloItemIsSet()) {
      content = widget.pertoloItem!.content;
      category = widget.pertoloItem!.category;
      type = widget.pertoloItem!.type;
    }
    super.initState();
  }

  void _updateItem(BuildContext context) async {
    String message = await PertoloItem.updateItem(
        widget.pertoloItem!, content, category, type);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    GoRouter.of(context).go('/edit');
  }

  void _createItem(BuildContext context) {
    String message = PertoloItem.createItem(content, category, type);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    setState(() {
      content = "";
    });
  }

  void _confirmItem(BuildContext context) {
    if (_pertoloItemIsSet()) {
      _updateItem(context);
    } else {
      _createItem(context);
    }
  }

  bool _pertoloItemIsSet() {
    return widget.pertoloItem != null;
  }

  @override
  Widget build(BuildContext context) {
    double height = 60;
    return ScreenContainer(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                SafeArea(
                    child: Container(
                        constraints: BoxConstraints(minHeight: height),
                        width: App.getMaxWidth(context),
                        child: TextField(
                          minLines: 1,
                          maxLines: 5,
                          style: ThemeData.dark().textTheme.labelMedium,
                          key: const Key('content'),
                          controller: TextEditingController(text: content),
                          onChanged: (value) => content = value,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Aufgabe/Frage',
                            labelStyle: ThemeData.dark().textTheme.labelMedium,
                          ),
                        ))),

                // dropdownbutton for category

                PertoloDropdown<String>(
                    items: App.categories
                        .map<DropdownMenuItem<String>>((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    value: category,
                    onChanged: (String? val) {
                      setState(() {
                        category = val!;
                      });
                    }),

                PertoloDropdown<ItemType>(
                    items: [ItemType.question, ItemType.task]
                        .map<DropdownMenuItem<ItemType>>((ItemType val) =>
                            DropdownMenuItem<ItemType>(
                                value: val, child: Text(val.name)))
                        .toList(),
                    value: type,
                    onChanged: (ItemType? val) {
                      setState(() {
                        type = val!;
                      });
                    }),
                const SizedBox(height: 45),
                PertoloButton(
                    onPressed: () => _confirmItem(context),
                    text: _pertoloItemIsSet() ? "Bearbeiten" : "Erstellen")
              ])),
          const Text(
              "Bitte ersetze alle Spielernamen durch einen Unterstrich ('_')",
              style: TextStyle(color: App.secondaryColor))
        ],
      )),
    );
  }
}
