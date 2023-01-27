import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pertolo_control/app.dart';
import 'package:pertolo_control/pertolo_item.dart';

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

  void _dislike() {
    if (items[index]
        .downvotes
        .contains(FirebaseAuth.instance.currentUser!.uid)) {
      items[index].downvotes.remove(FirebaseAuth.instance.currentUser!.uid);
    } else {
      items[index].downvotes.add(FirebaseAuth.instance.currentUser!.uid);
    }
    items[index].updateVotes();
    update();
  }

  List<PopupMenuItem<String>> _buildPopupMenuItemList(pertoloItem) {
    bool isOwner =
        pertoloItem.creatorUid == FirebaseAuth.instance.currentUser!.uid;
    if (isOwner) {
      return <PopupMenuItem<String>>[
        PopupMenuItem(
            value: "edit",
            child: ListTile(
              leading: const Icon(Icons.edit, color: App.whiteColor),
              title: Text("Bearbeiten",
                  style: ThemeData.dark().textTheme.headline6),
            )),
        PopupMenuItem(
          value: "delete",
          child: ListTile(
            leading: const Icon(Icons.delete, color: App.whiteColor),
            title: Text("Löschen", style: ThemeData.dark().textTheme.headline6),
          ),
        ),
      ];
    } else {
      return <PopupMenuItem<String>>[
        PopupMenuItem(
          value: "report",
          child: ListTile(
            leading: const Icon(Icons.report, color: App.whiteColor),
            title: Text("Melden", style: ThemeData.dark().textTheme.headline6),
          ),
        ),
        PopupMenuItem(
            value: "dislike",
            child: ListTile(
              leading: const Icon(Icons.thumb_down, color: App.whiteColor),
              title:
                  Text("Dislike", style: ThemeData.dark().textTheme.headline6),
            )),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        PopupMenuButton<String>(
            elevation: 20,
            color: App.primaryColor,
            icon: const Icon(Icons.more_vert, color: App.whiteColor),
            itemBuilder: (context) => _buildPopupMenuItemList(items[index]),
            onSelected: (String value) async {
              if (value == "edit") {
                GoRouter.of(context).goNamed("editItem", extra: items[index]);
              } else if (value == "delete") {
                await items[index].delete();
                items.removeAt(index);
                update();
              } else if (value == "dislike") {
                _dislike();
              }
            }),
      ],
    );
  }
}
