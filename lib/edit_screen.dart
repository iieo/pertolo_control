import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pertolo_control/components/pertolo_dropdown.dart';
import 'package:pertolo_control/edit_trailing_options.dart';
import 'package:pertolo_control/screen_container.dart';
import 'package:pertolo_control/app.dart';
import 'package:pertolo_control/pertolo_item.dart';

class EditScreen extends StatelessWidget {
  const EditScreen({super.key});
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
            return EditList(categories: snapshot.data!);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }),
        future: _loadCategories());
  }
}

class EditList extends StatefulWidget {
  final List<String> categories;
  const EditList({super.key, required this.categories});

  @override
  State<EditList> createState() => _EditListState();
}

class _EditListState extends State<EditList> {
  @override
  void initState() {
    super.initState();
    _updatePertoloItems();
  }

  void _updatePertoloItems() async {
    List<PertoloItem> items =
        await PertoloItem.loadPertoloItems(category, type);
    setState(() {
      this.items = items;
    });
  }

  List<PertoloItem> items = [];
  String category = "normal";
  ItemType type = ItemType.task;
  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          PertoloDropdown(
              items:
                  widget.categories.map<DropdownMenuItem<String>>((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val),
                );
              }).toList(),
              value: category,
              onChanged: (String? val) async {
                category = val!;
                _updatePertoloItems();
              }),
          PertoloDropdown(
              items: [ItemType.question, ItemType.task]
                  .map<DropdownMenuItem<ItemType>>((ItemType val) =>
                      DropdownMenuItem<ItemType>(
                          value: val, child: Text(val.name)))
                  .toList(),
              value: type,
              onChanged: (ItemType? val) async {
                type = val!;
                _updatePertoloItems();
              }),
          const SizedBox(height: 45),
          Expanded(
              child: ListView.separated(
            shrinkWrap: true,
            itemCount: items.length,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              return ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  title: Text(items[index].content,
                      style: ThemeData.dark().textTheme.headline6),
                  subtitle: Text(
                      items[index].creatorUid ==
                              FirebaseAuth.instance.currentUser!.uid
                          ? items[index].creator
                          : "Unbekannt",
                      style: const TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                        color: Color.fromARGB(255, 200, 200, 200),
                      )),
                  trailing: TrailingOptions(
                      items: items,
                      index: index,
                      update: () {
                        setState(() {});
                      }));
            },
            separatorBuilder: (context, index) {
              return const Divider(
                thickness: 2,
                color: App.secondaryColor,
              );
            },
          )),
        ],
      ),
    );
  }
}
