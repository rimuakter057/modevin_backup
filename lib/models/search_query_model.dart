import 'dart:convert';

class SearchQueryModel {
  final int? id;
  final int userId;
  final String queryText;
  final String filtersJson; // Map stored as JSON string

  SearchQueryModel({
    this.id,
    required this.userId,
    required this.queryText,
    required this.filtersJson,
  });

  factory SearchQueryModel.fromMap(Map<String, dynamic> map) {
    return SearchQueryModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      queryText: map['query_text'] as String,
      filtersJson: map['filters_json'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'query_text': queryText,
      'filters_json': filtersJson,
    };
  }

  Map<String, dynamic> get filters {
    try {
      return jsonDecode(filtersJson) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
