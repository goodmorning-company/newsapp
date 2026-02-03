import 'author_dto.dart';

class ArticleDto {
  final String id;
  final String title;
  final String content;
  final AuthorDto author;
  final String? thumbnailUrl;
  final List<String> tags;
  final int readingTimeMinutes;
  final String status;
  final DateTime publishedAt;
  final DateTime updatedAt;

  const ArticleDto({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    this.thumbnailUrl,
    this.tags = const [],
    required this.readingTimeMinutes,
    required this.status,
    required this.publishedAt,
    required this.updatedAt,
  });

  factory ArticleDto.fromRawData(String id, Map<String, dynamic> json) {
    return ArticleDto(
      id: id,
      title: json['title'] as String,
      content: json['content'] as String,
      author: AuthorDto.fromRawData(json['author'] as Map<String, dynamic>),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      readingTimeMinutes: (json['readingTimeMinutes'] as num).toInt(),
      status: (json['status'] as String).toLowerCase(),
      publishedAt: json['publishedAt'] as DateTime,
      updatedAt: json['updatedAt'] as DateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'author': author.toJson(),
      'thumbnailUrl': thumbnailUrl,
      'tags': List<String>.from(tags),
      'readingTimeMinutes': readingTimeMinutes,
      'status': status,
      'publishedAt': publishedAt,
      'updatedAt': updatedAt,
    };
  }
}
