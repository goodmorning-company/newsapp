import 'dart:developer' as dev;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    const collectionPath = 'articles';
    final articleId = article.id.isEmpty
        ? FirebaseFirestore.instance.collection(collectionPath).doc().id
        : article.id;

    try {
      dev.log('Firebase CREATE start → $articleId', name: 'publish.firestore');

      // 1. Upload real cover image
      final imagePath = article.coverImageUrl;
      if (imagePath == null || imagePath.isEmpty) {
        throw StateError('Missing cover image path');
      }

      final coverBytes = await File(imagePath).readAsBytes();
      final ref = _storage.ref().child('media/articles/$articleId/cover.jpg');

      await ref.putData(
        coverBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final coverUrl = await ref.getDownloadURL();

      // 2. Normalize required fields for Firestore rules
      final now = DateTime.now().toUtc();

      final articleForWrite = article.copyWith(
        id: articleId,
        coverImageUrl: coverUrl,
        summary: article.summary.isNotEmpty
            ? article.summary
            : _generateSummary(article.body),
        updatedAt: now,
        readingTimeMinutes: article.readingTimeMinutes > 0
            ? article.readingTimeMinutes
            : _estimateReadingTime(article.body),
      );
      final publishedAtTimestamp = Timestamp.fromDate(
        articleForWrite.publishedAt.toUtc(),
      );
      final updatedAtTimestamp = Timestamp.fromDate(
        articleForWrite.updatedAt.toUtc(),
      );

      dev.log(
        'Firestore data check | coverImageUrl=${articleForWrite.coverImageUrl} '
        'bodyLen=${articleForWrite.body.length} '
        'summaryLen=${articleForWrite.summary.length} '
        'readingTimeMinutes=${articleForWrite.readingTimeMinutes}',
        name: 'publish.firestore',
      );

      final dto = _mapToDto(articleForWrite);

      dev.log('[ABOUT_TO_SEND]', name: '[publish.payload]');

      dev.log('''
      [id]=${articleForWrite.id}
      [title]=${articleForWrite.title}
      [summaryLen]=${articleForWrite.summary.length}
      [bodyLen]=${articleForWrite.body.length}
      [author.id]=${articleForWrite.author.id}
      [author.name]=${articleForWrite.author.name}
      [coverImageUrl]=${articleForWrite.coverImageUrl}
      [tags]=${articleForWrite.tags}
      [readingTimeMinutes]=${articleForWrite.readingTimeMinutes}
      [status]=${articleForWrite.status}
      [publishedAt]=$publishedAtTimestamp
      [updatedAt]=$updatedAtTimestamp
      ''', name: '[publish.payload]');

      final payload = <String, dynamic>{
        'title': dto.title,
        'summary': dto.summary,
        'body': articleForWrite.body,
        'author': dto.author.toJson(),
        'tags': List<String>.from(dto.tags),
        'coverImageUrl': articleForWrite.coverImageUrl,
        'readingTimeMinutes': dto.readingTimeMinutes,
        'status': dto.status,
        'publishedAt': publishedAtTimestamp,
        'updatedAt': updatedAtTimestamp,
      };

      // 3. Write document
      await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(articleId)
          .set(payload);

      dev.log(
        'Firestore write success | docId=$articleId',
        name: 'publish.firestore',
      );
    } catch (error, stack) {
      dev.log(
        'Firestore write error | $error',
        name: 'publish.firestore',
        error: error,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  // ----------------------------
  // Mapping
  // ----------------------------

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
      coverImageUrl: dto.thumbnailUrl ?? dto.coverImageUrl,
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

  // ----------------------------
  // Helpers
  // ----------------------------

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

  int _estimateReadingTime(String text) {
    final words = text.trim().split(RegExp(r'\s+')).length;
    return (words / 200).clamp(1, 60).ceil();
  }
}
