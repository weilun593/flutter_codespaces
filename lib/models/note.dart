class Note {
  const Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.tag,
    required this.color,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String content;
  final String tag;
  final String color;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      tag: map['tag'] as String? ?? '未分類',
      color: map['color'] as String? ?? 'indigo',
      isPinned: map['is_pinned'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(map['updated_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toInsertMap(String ownerId) {
    return {
      'user_id': ownerId,
      'title': title,
      'content': content,
      'tag': tag,
      'color': color,
      'is_pinned': isPinned,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'content': content,
      'tag': tag,
      'color': color,
      'is_pinned': isPinned,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  Note copyWith({
    String? title,
    String? content,
    String? tag,
    String? color,
    bool? isPinned,
  }) {
    return Note(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      tag: tag ?? this.tag,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
