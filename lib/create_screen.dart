import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pertolo_control/ScreenContainer.dart';
import 'package:pertolo_control/main.dart';
import 'package:pertolo_control/pertolo_item.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});
  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  String content = "";
  String category = "normal";
  ItemType type = ItemType.task;

  Future<List<String>> _loadCategories() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('game').get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }

  void _createItem(BuildContext context) {
    if (content.isEmpty) {
      SnackBar snackBar =
          const SnackBar(content: Text('Bitte gib einen Inhalt ein'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    Map<String, String> docData = {
      'creatorUid': FirebaseAuth.instance.currentUser!.uid,
      'creator': FirebaseAuth.instance.currentUser!.displayName!,
      'content': content,
    };

    try {
      FirebaseFirestore.instance
          .collection('game')
          .doc(category)
          .collection(type.name)
          .add(docData);
    } catch (e) {
      SnackBar snackBar = SnackBar(content: Text('Error: $e'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    SnackBar snackBar = const SnackBar(content: Text('Aufgabe/Frage erstellt'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    setState(() {
      content = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = max(200, MediaQuery.of(context).size.width * 0.3);
    double height = 60;
    return ScreenContainer(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              constraints: BoxConstraints(minHeight: height),
              width: width,
              child: TextField(
                minLines: 1,
                maxLines: 5,
                style: const TextStyle(color: App.secondaryColor),
                key: const ValueKey('content'),
                controller: TextEditingController(text: content),
                onChanged: (value) => content = value,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Aufgabe/Frage',
                  labelStyle: TextStyle(color: App.secondaryColor),
                ),
              )),
          FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == null || snapshot.hasError) {
                    return Container();
                  }
                  return
                      // dropdownbutton for category
                      SizedBox(
                          width: width,
                          height: height,
                          child: DropdownButton<String>(
                              value: category,
                              style: const TextStyle(color: App.secondaryColor),
                              dropdownColor: App.primaryColor,
                              items: snapshot.data!
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
                              }));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
              future: _loadCategories()),
          SizedBox(
              width: width,
              height: height,
              child: DropdownButton<ItemType>(
                  value: type,
                  style: const TextStyle(color: App.secondaryColor),
                  dropdownColor: App.primaryColor,
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
          const SizedBox(height: 20),
          SizedBox(
              height: height,
              width: width,
              child: ElevatedButton(
                  onPressed: () => _createItem(context),
                  child: const Text('Create',
                      style: TextStyle(color: App.primaryColor)))),
          const SizedBox(height: 20),
          const Text(
              "Bitte ersetze alle Spielernamen durch einen Unterstrich ('_')",
              style: TextStyle(color: App.secondaryColor))
        ],
      )),
    );
  }
}
