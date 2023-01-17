import 'package:cloud_firestore/cloud_firestore.dart';

class PertoloItem {
  String id;
  String creatorUid;
  String creator;
  String category;
  String content;
  ItemType type;
  List<String> upvotes;
  List<String> downvotes;

  PertoloItem(
      {required this.id,
      required this.creatorUid,
      required this.creator,
      required this.category,
      required this.content,
      required this.type,
      this.upvotes = const [],
      this.downvotes = const []});

  @override
  String toString() {
    return 'PertoloItem{creatorUid: $creatorUid, creator: $creator, category: $category, content: $content, type: $type, upvotes: $upvotes, downvotes: $downvotes}';
  }

  static PertoloItem fromMap(
      String id, Map<String, dynamic> map, String category, ItemType type) {
    return PertoloItem(
        id: id,
        creatorUid: map['creatorUid'],
        creator: map['creator'],
        category: category,
        content: map['content'],
        type: type,
        upvotes: List<String>.from(map['upvotes'] ?? []),
        downvotes: List<String>.from(map['downvotes'] ?? []));
  }

  static Future<List<PertoloItem>> loadPertoloItems(
      String category, ItemType type) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('game')
          .doc(category)
          .collection(type.name)
          .get();
      return snapshot.docs
          .map((doc) => PertoloItem.fromMap(
              doc.id, doc.data() as Map<String, dynamic>, category, type))
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> save() async {
    try {
      await FirebaseFirestore.instance
          .collection('game')
          .doc(category)
          .collection(type.name)
          .doc(id)
          .update({'upvotes': upvotes, 'downvotes': downvotes});
    } catch (e) {
      print(e);
    }
  }

  Future<void> delete() async {
    try {
      await FirebaseFirestore.instance
          .collection('game')
          .doc(category)
          .collection(type.name)
          .doc(id)
          .delete();
    } catch (e) {
      print(e);
    }
  }
}

enum ItemType { task, question }
