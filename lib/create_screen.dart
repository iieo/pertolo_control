import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pertolo_control/components/pertolo_button.dart';
import 'package:pertolo_control/components/pertolo_dropdown.dart';
import 'package:pertolo_control/screen_container.dart';
import 'package:pertolo_control/app.dart';
import 'package:pertolo_control/pertolo_item.dart';

class CreateScreen extends StatelessWidget {
  final String? pertoloItemId;
  final String? pertoloItemCategory;
  final String? pertoloItemType;
  const CreateScreen(
      {super.key,
      this.pertoloItemId,
      this.pertoloItemCategory,
      this.pertoloItemType});
  Future<List<String>> _loadCategories() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('game').get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }

  Future<PertoloItem?> _loadPertoloItem() async {
    if (pertoloItemId == null ||
        pertoloItemCategory == null ||
        pertoloItemType == null) {
      return null;
    }
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('game')
          .doc(pertoloItemCategory)
          .collection(pertoloItemType!)
          .doc(pertoloItemId)
          .get();
      return PertoloItem.fromMap(
          snapshot.id,
          snapshot.data() as Map<String, dynamic>,
          pertoloItemCategory!,
          ItemType.values
              .firstWhere((element) => element.name == pertoloItemType));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: ((context, pertoloSnapshot) {
        if (pertoloSnapshot.connectionState == ConnectionState.done) {
          if (pertoloSnapshot.hasError) {
            return const Text(
                "Cannot load pertolo item data. No internet connection?");
          }
          return FutureBuilder(
            builder: ((context, categoriesSnapshot) {
              if (categoriesSnapshot.connectionState == ConnectionState.done) {
                if (categoriesSnapshot.data == null ||
                    categoriesSnapshot.hasError) {
                  return const Text(
                      "Cannot load categories data. No internet connection?");
                }
                return CreateForm(
                    categories: categoriesSnapshot.data!,
                    pertoloItem: pertoloSnapshot.data);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
            future: _loadCategories(),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      }),
      future: _loadPertoloItem(),
    );
  }
}

class CreateForm extends StatefulWidget {
  final List<String> categories;
  final PertoloItem? pertoloItem;
  const CreateForm({super.key, required this.categories, this.pertoloItem});

  @override
  State<CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {
  String content = "";
  String category = "normal";
  ItemType type = ItemType.task;

  @override
  void initState() {
    super.initState();
    if (_pertoloItemIsSet()) {
      setState(() {
        content = widget.pertoloItem!.content;
        category = widget.pertoloItem!.category;
        type = widget.pertoloItem!.type;
      });
    }
  }

  void _updateItem(BuildContext context) async {
    String message = await PertoloItem.updateItem(
        content, category, type, widget.pertoloItem!);

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

                PertoloDropdown<String>(
                    items: widget.categories
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
