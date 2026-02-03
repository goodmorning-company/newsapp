import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/article.dart';
import '../../domain/entities/author.dart';
import '../../domain/repository/article_repository.dart';
import '../data_sources/article_remote_data_source.dart';
import '../models/article_dto.dart';
import '../models/author_dto.dart';

class FirebaseArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource _remote;
  final FirebaseStorage _storage;

  FirebaseArticleRepositoryImpl(
    ArticleRemoteDataSource remote, {
    FirebaseStorage? storage,
  }) : _remote = remote,
       _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<List<Article>> getArticles({int? limit}) async {
    final dtos = await _remote.fetchLatest(limit: limit);
    return dtos.map(_mapToDomain).toList();
  }

  @override
  Future<Article> getArticleById(String id) async {
    final dto = await _remote.fetchById(id);
    if (dto == null) {
      throw StateError('Article not found for id $id');
    }
    return _mapToDomain(dto);
  }

  @override
  Future<void> createArticle(Article article) async {
    // Ensure we have an id before upload/write.
    final articleId = article.id.isEmpty
        ? FirebaseFirestore.instance.collection('articles').doc().id
        : article.id;
    final coverBytes = _placeholderImageBytes();

    try {
      debugPrint('Firebase CREATE start → $articleId');

      // Upload cover image first
      final ref = _storage.ref().child('media/articles/$articleId/cover.jpg');
      await ref.putData(
        coverBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final coverUrl = await ref.getDownloadURL();

      final dto = _mapToDto(
        article.copyWith(
          id: articleId,
          coverImageUrl: coverUrl,
          summary: article.summary.isNotEmpty
              ? article.summary
              : _generateSummary(article.body),
        ),
      );

      await _remote.createArticle(dto);
      debugPrint('Firebase CREATE OK → $articleId');
    } catch (error, stack) {
      debugPrint('Firebase CREATE ERROR → fallback to mock : $error');
      debugPrintStack(stackTrace: stack);
      // Fallback to mock repository behavior by throwing so upper layer can delegate.
      rethrow;
    }
  }

  Article _mapToDomain(ArticleDto dto) {
    final status = dto.status.toLowerCase() == 'published'
        ? ArticleStatus.published
        : ArticleStatus.draft;
    return Article(
      id: dto.id,
      title: dto.title,
      body: dto.content,
      summary: dto.summary,
      author: _mapAuthorToDomain(dto.author),
      coverImageUrl: dto.thumbnailUrl,
      tags: dto.tags,
      readingTimeMinutes: dto.readingTimeMinutes,
      status: status,
      publishedAt: dto.publishedAt,
      updatedAt: dto.updatedAt,
    );
  }

  Author _mapAuthorToDomain(AuthorDto dto) {
    return Author(
      id: dto.id,
      name: dto.name,
      bio: dto.bio,
      avatarUrl: dto.avatarUrl,
    );
  }

  ArticleDto _mapToDto(Article article) {
    return ArticleDto(
      id: article.id,
      title: article.title,
      content: article.body,
      summary: article.summary,
      author: _mapAuthorToDto(article.author),
      thumbnailUrl: article.coverImageUrl,
      tags: List<String>.from(article.tags),
      readingTimeMinutes: article.readingTimeMinutes,
      status: article.status.name,
      publishedAt: article.publishedAt,
      updatedAt: article.updatedAt,
    );
  }

  AuthorDto _mapAuthorToDto(Author author) {
    return AuthorDto(
      id: author.id,
      name: author.name,
      bio: author.bio,
      avatarUrl: author.avatarUrl,
    );
  }

  String _generateSummary(String body) {
    final normalized = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return '';
    const minChars = 160;
    const maxChars = 200;
    if (normalized.length <= maxChars) return normalized;
    final slice = normalized.substring(0, maxChars);
    final lastSpace = slice.lastIndexOf(' ');
    final safe = lastSpace >= minChars ? slice.substring(0, lastSpace) : slice;
    return safe.trim();
  }

  Uint8List _placeholderImageBytes() {
    // Minimal valid JPEG header bytes to satisfy Storage rules.
    return Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]);
  }
}
