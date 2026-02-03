import 'dart:async';

import '../../domain/entities/article.dart';
import '../../domain/repository/article_repository.dart';
import '../../domain/use_cases/mock_articles.dart';

class MockArticleRepositoryImpl implements ArticleRepository {
  final Duration latency;
  final List<Article> _articles;
  int _sequence;

  MockArticleRepositoryImpl({
    this.latency = const Duration(milliseconds: 180),
    List<Article>? seedArticles,
  })  : _articles = List<Article>.from(seedArticles ?? mockArticles),
        _sequence = (seedArticles ?? mockArticles).length;

  static List<Article> seedData() => List<Article>.from(mockArticles);

  @override
  Future<List<Article>> getArticles({int? limit}) async {
    final sorted = List<Article>.from(_articles)
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    final result = limit == null ? sorted : sorted.take(limit).toList();
    return Future<List<Article>>.delayed(latency, () => result);
  }

  @override
  Future<Article> getArticleById(String id) async {
    return Future<Article>.delayed(latency, () {
      final match = _articles.firstWhere(
        (article) => article.id == id,
        orElse: () => throw StateError('Article not found: $id'),
      );
      return match;
    });
  }

  @override
  Future<void> createArticle(Article article) async {
    await Future<void>.delayed(latency, () {
      if (article.id.isNotEmpty &&
          _articles.any((existing) => existing.id == article.id)) {
        throw StateError('Article id already exists: ${article.id}');
      }
      final stored = article.id.isEmpty
          ? article.copyWith(id: _nextId(), publishedAt: DateTime.now())
          : article;
      _articles.insert(0, stored);
    });
  }

  String _nextId() {
    _sequence += 1;
    return 'mock-article-${_sequence.toString().padLeft(3, '0')}';
  }
}
