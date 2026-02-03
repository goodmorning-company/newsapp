import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/article_dto.dart';

class ArticleRemoteDataSource {
  final CollectionReference<Map<String, dynamic>> _articles;

  ArticleRemoteDataSource(FirebaseFirestore firestore)
      : _articles = firestore.collection('articles');

  Future<List<ArticleDto>> fetchLatest({int? limit}) async {
    Query<Map<String, dynamic>> query =
        _articles.orderBy('publishedAt', descending: true);
    if (limit != null) {
      query = query.limit(limit);
    }
    final snapshot = await query.get();
    return snapshot.docs.map(_mapSnapshotToDto).toList();
  }

  Future<ArticleDto?> fetchById(String id) async {
    final doc = await _articles.doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return _mapSnapshotToDto(doc);
  }

  Future<List<ArticleDto>> fetchByAuthor(String authorId, {int? limit}) async {
    Query<Map<String, dynamic>> query = _articles
        .where('author.id', isEqualTo: authorId)
        .orderBy('publishedAt', descending: true);
    if (limit != null) {
      query = query.limit(limit);
    }
    final snapshot = await query.get();
    return snapshot.docs.map(_mapSnapshotToDto).toList();
  }

  Future<ArticleDto> createArticle(ArticleDto dto) async {
    final docRef = dto.id.isEmpty ? _articles.doc() : _articles.doc(dto.id);

    final ArticleDto toStore = dto.id.isEmpty
        ? ArticleDto(
            id: docRef.id,
            title: dto.title,
            content: dto.content,
            summary: _summaryFrom(dto.content, dto.summary),
            author: dto.author,
            thumbnailUrl: dto.thumbnailUrl,
            tags: List<String>.from(dto.tags),
            readingTimeMinutes: dto.readingTimeMinutes,
            status: dto.status,
            publishedAt: dto.publishedAt,
            updatedAt: dto.updatedAt,
          )
        : dto.summary.isEmpty
            ? ArticleDto(
                id: dto.id,
                title: dto.title,
                content: dto.content,
                summary: _summaryFrom(dto.content, dto.summary),
                author: dto.author,
                thumbnailUrl: dto.thumbnailUrl,
                tags: List<String>.from(dto.tags),
                readingTimeMinutes: dto.readingTimeMinutes,
                status: dto.status,
                publishedAt: dto.publishedAt,
                updatedAt: dto.updatedAt,
              )
            : dto;

    await docRef.set(_encodeForFirestore(toStore));
    final stored = await docRef.get();
    return _mapSnapshotToDto(stored);
  }

  ArticleDto _mapSnapshotToDto(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Article document is empty for id ${doc.id}');
    }
    final json = Map<String, dynamic>.from(data);
    json['publishedAt'] = _asDateTime(json['publishedAt'], 'publishedAt');
    json['updatedAt'] = _asDateTime(json['updatedAt'], 'updatedAt');
    json['summary'] = (json['summary'] as String?) ?? '';
    return ArticleDto.fromRawData(doc.id, json);
  }

  Map<String, dynamic> _encodeForFirestore(ArticleDto dto) {
    final map = dto.toJson();
    return {
      ...map,
      'publishedAt': Timestamp.fromDate(dto.publishedAt.toUtc()),
      'updatedAt': Timestamp.fromDate(dto.updatedAt.toUtc()),
    };
  }
}

DateTime _asDateTime(Object? value, String fieldName) {
  if (value is Timestamp) return value.toDate().toUtc();
  if (value is DateTime) return value.toUtc();
  throw StateError('Invalid $fieldName value: $value');
}

String _summaryFrom(String content, String existing) {
  if (existing.isNotEmpty) return existing;
  final normalized = content.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) return '';
  const minChars = 160;
  const maxChars = 200;
  if (normalized.length <= maxChars) return normalized;
  final slice = normalized.substring(0, maxChars);
  final lastSpace = slice.lastIndexOf(' ');
  final safe = lastSpace >= minChars ? slice.substring(0, lastSpace) : slice;
  return safe.trim();
}
