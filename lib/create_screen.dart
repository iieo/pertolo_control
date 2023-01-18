import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pertolo_control/ScreenContainer.dart';
import 'package:pertolo_control/main.dart';
import 'package:pertolo_control/pertolo_item.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});
  Future<List<String>> _loadCategories() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('game').get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == null || snapshot.hasError) {
              return const Text("Cannot load categories data");
            }
            return CreateForm(categories: snapshot.data!);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }),
        future: _loadCategories());
  }
}

class CreateForm extends StatefulWidget {
  final List<String> categories;
  const CreateForm({super.key, required this.categories});

  @override
  State<CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {
  String content = "";
  String category = "normal";
  ItemType type = ItemType.task;

  void _createItem(BuildContext context) {
    String message = PertoloItem.createItem(content, category, type);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    setState(() {
      content = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 100;
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
                Container(
                    constraints: BoxConstraints(minHeight: height),
                    width: width,
                    child: TextField(
                      minLines: 1,
                      maxLines: 5,
                      style: ThemeData.dark().textTheme.labelMedium,
                      key: const ValueKey('content'),
                      controller: TextEditingController(text: content),
                      onChanged: (value) => content = value,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Aufgabe/Frage',
                        labelStyle: ThemeData.dark().textTheme.labelMedium,
                      ),
                    )),

                // dropdownbutton for category
                SizedBox(
                    width: width,
                    height: height,
                    child: DropdownButton<String>(
                        value: category,
                        style: ThemeData.dark().textTheme.button,
                        dropdownColor: App.secondaryColor,
                        items: widget.categories
                            .map<DropdownMenuItem<String>>((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (String? val) {
                          setState(() {
                            category = val!;
                          });
                        })),

                SizedBox(
                    width: width,
                    height: height,
                    child: DropdownButton<ItemType>(
                        value: type,
                        style: ThemeData.dark().textTheme.button,
                        dropdownColor: App.secondaryColor,
                        items: [ItemType.question, ItemType.task]
                            .map<DropdownMenuItem<ItemType>>((ItemType val) =>
                                DropdownMenuItem<ItemType>(
                                    value: val, child: Text(val.name)))
                            .toList(),
                        onChanged: (ItemType? val) {
                          setState(() {
                            type = val!;
                          });
                        })),
                const SizedBox(height: 45),
                SizedBox(
                    height: height,
                    width: width,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: App.secondaryColor),
                        onPressed: () => _createItem(context),
                        child: Text('Create',
                            style: ThemeData.dark().textTheme.button)))
              ])),
          const Text(
              "Bitte ersetze alle Spielernamen durch einen Unterstrich ('_')",
              style: TextStyle(color: App.secondaryColor))
        ],
      )),
    );
  }
}
