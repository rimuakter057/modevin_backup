class BookmarkModel {
  final int? id;
  final int userId;
  final int listingId;

  BookmarkModel({
    this.id,
    required this.userId,
    required this.listingId,
  });

  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      listingId: map['listing_id'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'listing_id': listingId,
    };
  }
}
