import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    double width = MediaQuery.of(context).size.width - 100;
    double height = 60;
    return ScreenContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
                  onChanged: (String? val) async {
                    category = val!;
                    _updatePertoloItems();
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
                  onChanged: (ItemType? val) async {
                    type = val!;
                    _updatePertoloItems();
                  })),
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
                  subtitle: Text(items[index].creator,
                      style: ThemeData.dark().textTheme.subtitle1),
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

class TrailingOptions extends StatelessWidget {
  final int index;
  final List<PertoloItem> items;
  final Function update;
  late String votes;
  TrailingOptions(
      {super.key,
      required this.items,
      required this.index,
      required this.update}) {
    int votesScore =
        items[index].upvotes.length - items[index].downvotes.length;
    votes = votesScore > 0 ? "+$votesScore" : votesScore.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible:
              items[index].creatorUid == FirebaseAuth.instance.currentUser!.uid,
          child: IconButton(
              onPressed: () async {
                await items[index].delete();
                items.removeAt(index);
                update();
              },
              icon: const Icon(Icons.delete, color: App.whiteColor)),
        ),
        const SizedBox(width: 20),
        Text(votes, style: const TextStyle(color: App.whiteColor)),
        IconButton(
            onPressed: () async {
              if (items[index]
                  .upvotes
                  .contains(FirebaseAuth.instance.currentUser!.uid)) {
                items[index]
                    .upvotes
                    .remove(FirebaseAuth.instance.currentUser!.uid);
              } else {
                items[index]
                    .upvotes
                    .add(FirebaseAuth.instance.currentUser!.uid);
              }
              await items[index].updateVotes();
              update();
            },
            icon: Icon(Icons.thumb_up,
                color: items[index]
                        .upvotes
                        .contains(FirebaseAuth.instance.currentUser!.uid)
                    ? App.secondaryColor
                    : App.whiteColor)),
        IconButton(
            onPressed: () async {
              if (items[index]
                  .downvotes
                  .contains(FirebaseAuth.instance.currentUser!.uid)) {
                items[index]
                    .downvotes
                    .remove(FirebaseAuth.instance.currentUser!.uid);
              } else {
                items[index]
                    .downvotes
                    .add(FirebaseAuth.instance.currentUser!.uid);
              }
              await items[index].updateVotes();
              update();
            },
            icon: Icon(Icons.thumb_down,
                color: items[index]
                        .downvotes
                        .contains(FirebaseAuth.instance.currentUser!.uid)
                    ? App.secondaryColor
                    : App.whiteColor)),
      ],
    );
  }
}
