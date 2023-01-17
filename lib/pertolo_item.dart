class PertoloItem {
  String creatorUid;
  String creator;
  String category;
  String content;
  ItemType type;
  int upvotes;
  int downvotes;

  PertoloItem(
      {required this.creatorUid,
      required this.creator,
      required this.category,
      required this.content,
      required this.type,
      this.upvotes = 0,
      this.downvotes = 0});

  @override
  String toString() {
    return 'PertoloItem{creatorUid: $creatorUid, creator: $creator, category: $category, content: $content, type: $type, upvotes: $upvotes, downvotes: $downvotes}';
  }

  PertoloItem.fromJson(Map<String, dynamic> json)
      : creatorUid = json['creatorUid'],
        creator = json['creator'],
        category = json['category'],
        content = json['content'],
        type = json['type'],
        upvotes = json['upvotes'],
        downvotes = json['downvotes'];
}

enum ItemType { task, question }
