import 'dart:developer' as dev;

import 'author_dto.dart';

class ArticleDto {
  final String id;
  final String title;
  final String content;
  final String summary;
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
    required this.summary,
    required this.author,
    this.thumbnailUrl,
    this.tags = const [],
    required this.readingTimeMinutes,
    required this.status,
    required this.publishedAt,
    required this.updatedAt,
  });

  String? get coverImageUrl => thumbnailUrl;

  factory ArticleDto.fromRawData(String id, Map<String, dynamic> json) {
    dev.log(
      '[[feed.firebase.raw]] [DOC]\n[id]=$id\n[keys]=${json.keys.toList()}',
      name: 'feed.firestore',
    );
    dev.log(
      '[[feed.firebase.raw]] [FIELDS]\n'
      '[title]=${json['title']}\n'
      '[summary]=${json['summary']}\n'
      '[body]=${json['body']}\n'
      '[status]=${json['status']}\n'
      '[thumbnailUrl]=${json['thumbnailUrl']}\n'
      '[coverImageUrl]=${json['coverImageUrl']}\n'
      '[author]=${json['author']}\n'
      '[tags]=${json['tags']}\n'
      '[publishedAt]=${json['publishedAt']}\n'
      '[updatedAt]=${json['updatedAt']}',
      name: 'feed.firestore',
    );
    final coverImageUrl = json['coverImageUrl'] as String?;
    final thumbnailUrl = json['thumbnailUrl'] as String?;
    final rawAuthor = json['author'];
    final authorData = rawAuthor is Map<String, dynamic>
        ? rawAuthor
        : <String, dynamic>{};
    final publishedAt = json['publishedAt'];
    final updatedAt = json['updatedAt'];
    return ArticleDto(
      id: id,
      title: (json['title'] as String?) ?? '',
      content: (json['content'] as String?) ?? (json['body'] as String?) ?? '',
      summary: json['summary'] as String? ?? '',
      author: AuthorDto.fromRawData({
        'id': (authorData['id'] as String?) ?? '',
        'name': (authorData['name'] as String?) ?? '',
        'bio': authorData['bio'] as String?,
        'avatarUrl': authorData['avatarUrl'] as String?,
      }),
      thumbnailUrl: coverImageUrl ?? thumbnailUrl,
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      readingTimeMinutes: (json['readingTimeMinutes'] as num?)?.toInt() ?? 1,
      status: ((json['status'] as String?) ?? 'draft').toLowerCase(),
      publishedAt: publishedAt is DateTime ? publishedAt : DateTime.now().toUtc(),
      updatedAt: updatedAt is DateTime ? updatedAt : DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'summary': summary,
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
