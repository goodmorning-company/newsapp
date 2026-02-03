import 'author.dart';

enum ArticleStatus { draft, published }

class Article {
  final String id;
  final String title;
  final String body;
  final Author author;
  final String? coverImageUrl;
  final List<String> tags;
  final int readingTimeMinutes;
  final ArticleStatus status;
  final DateTime publishedAt;
  final DateTime updatedAt;

  const Article({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
    this.coverImageUrl,
    this.tags = const [],
    required this.readingTimeMinutes,
    required this.status,
    required this.publishedAt,
    required this.updatedAt,
  });

  bool get isPublished => status == ArticleStatus.published;

  Article copyWith({
    String? id,
    String? title,
    String? body,
    Author? author,
    String? coverImageUrl,
    List<String>? tags,
    int? readingTimeMinutes,
    ArticleStatus? status,
    DateTime? publishedAt,
    DateTime? updatedAt,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      author: author ?? this.author,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      tags: tags ?? List<String>.from(this.tags),
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      status: status ?? this.status,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Article &&
            other.id == id &&
            other.title == title &&
            other.body == body &&
            other.author == author &&
            other.coverImageUrl == coverImageUrl &&
            _listEquals(other.tags, tags) &&
            other.readingTimeMinutes == readingTimeMinutes &&
            other.status == status &&
            other.publishedAt == publishedAt &&
            other.updatedAt == updatedAt);
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        body,
        author,
        coverImageUrl,
        Object.hashAll(tags),
        readingTimeMinutes,
        status,
        publishedAt,
        updatedAt,
      );
}

bool _listEquals(List<Object?> a, List<Object?> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
