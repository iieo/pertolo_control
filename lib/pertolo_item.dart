import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PertoloItem {
  String id;
  String creatorUid;
  String creator;
  String category;
  String content;
  ItemType type;
  List<String> upvotes;
  List<String> downvotes;
  DateTime created;
  DateTime updated;

  PertoloItem({
    required this.id,
    required this.creatorUid,
    required this.creator,
    required this.category,
    required this.content,
    required this.type,
    this.upvotes = const [],
    this.downvotes = const [],
    required this.created,
    required this.updated,
  });

  @override
  String toString() {
    return 'PertoloItem{creatorUid: $creatorUid, creator: $creator, category: $category, content: $content, type: $type, upvotes: $upvotes, downvotes: $downvotes}';
  }

  static Timestamp _fromTimestampString(String timestamp) {
    int nanoSeconds = int.parse(
        timestamp.split(',').last.split('=').last.replaceFirst(")", ""));
    int seconds = int.parse(timestamp.split(',').first.split('=').last);
    return Timestamp(seconds, nanoSeconds);
  }

  static PertoloItem fromMap(
      String id, Map<String, dynamic> map, String category, ItemType type) {
    var timestampCreated = map['created'];
    var timestampUpdated = map['updated'];
    if (timestampCreated is String) {
      timestampCreated = Timestamp.now();
    }
    if (timestampUpdated is String) {
      timestampUpdated = Timestamp.now();
    }

    return PertoloItem(
        id: id,
        creatorUid: map['creatorUid'],
        creator: map['creator'],
        category: category,
        content: map['content'],
        type: type,
        upvotes: List<String>.from(map['upvotes'] ?? []),
        downvotes: List<String>.from(map['downvotes'] ?? []),
        created: timestampCreated.toDate(),
        updated: timestampUpdated.toDate());
  }

  static Future<List<PertoloItem>> loadPertoloItems(
      String category, ItemType type) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('game')
          .doc(category)
          .collection(type.name)
          .get();
      List<PertoloItem> items = snapshot.docs
          .map((doc) => PertoloItem.fromMap(
              doc.id, doc.data() as Map<String, dynamic>, category, type))
          .toList();
      return items;
    } catch (e) {
      print(e);
      return [];
    }
  }

  static String createItem(String content, String category, ItemType type) {
    if (content.trim().isEmpty || content.trim().length < 5) {
      return 'Bitte gib einen Inhalt ein';
    }
    Map<String, dynamic> docData = {
      'creatorUid': FirebaseAuth.instance.currentUser!.uid,
      'creator': FirebaseAuth.instance.currentUser!.displayName!,
      'content': content,
      'created': Timestamp.now(),
      'updated': Timestamp.now(),
    };
    try {
      FirebaseFirestore.instance
          .collection('game')
          .doc(category)
          .collection(type.name)
          .add(docData);
    } catch (e) {
      return 'Fehler beim Speichern: $e';
    }
    return 'Aufgabe gespeichert';
  }

  Future<void> updateVotes() async {
    try {
      await FirebaseFirestore.instance
          .collection('game')
          .doc(category)
          .collection(type.name)
          .doc(id)
          .update(
              {'upvotes': upvotes, 'downvotes': downvotes, 'updated': updated});
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveDate() async {
    try {
      await FirebaseFirestore.instance
          .collection('game')
          .doc(category)
          .collection(type.name)
          .doc(id)
          .update({'updated': Timestamp.now(), 'created': Timestamp.now()});
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
