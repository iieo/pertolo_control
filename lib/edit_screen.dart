import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pertolo_control/components/pertolo_dropdown.dart';
import 'package:pertolo_control/edit_trailing_options.dart';
import 'package:pertolo_control/screen_container.dart';
import 'package:pertolo_control/app.dart';
import 'package:pertolo_control/pertolo_item.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  List<PertoloItem> allItems = [];
  List<PertoloItem> items = [];
  String category = "normal";
  ItemType type = ItemType.task;
  bool _isMyTasksFilter = false;

  void _filterMyTasks(bool change) {
    bool isActive = change ? !_isMyTasksFilter : _isMyTasksFilter;
    if (isActive) {
      items = allItems
          .where((element) =>
              element.creatorUid == FirebaseAuth.instance.currentUser!.uid)
          .toList();
    } else {
      items = allItems;
    }
    setState(() {
      _isMyTasksFilter = isActive;
    });
  }

  @override
  void initState() {
    super.initState();
    _updatePertoloItems();
  }

  void _updatePertoloItems() async {
    allItems = await PertoloItem.loadPertoloItems(category, type);
    _filterMyTasks(false);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          PertoloDropdown(
              items: App.categories.map<DropdownMenuItem<String>>((String val) {
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
          Container(
              padding: EdgeInsets.symmetric(
                  vertical: 10, horizontal: App.getPaddingHorizontal(context)),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _filterMyTasks(true),
                    child: Chip(
                      label: Text("Meine Aufgaben",
                          style: TextStyle(
                              color: _isMyTasksFilter
                                  ? App.whiteColor
                                  : App.primaryColor)),
                      avatar: Icon(Icons.person,
                          color: _isMyTasksFilter
                              ? App.whiteColor
                              : App.primaryColor),
                      backgroundColor: _isMyTasksFilter
                          ? App.secondaryColor
                          : App.whiteColor,
                    ),
                  ),
                ],
              )),
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
