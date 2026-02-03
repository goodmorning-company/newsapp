import 'dart:async';

import '../../domain/entities/article.dart';
import '../../domain/entities/author.dart';
import '../../domain/repository/article_repository.dart';

class MockArticleRepositoryImpl implements ArticleRepository {
  final Duration latency;
  final List<Article> _articles;
  int _sequence;

  MockArticleRepositoryImpl({
    this.latency = const Duration(milliseconds: 180),
    List<Article>? seedArticles,
  })  : _articles = List<Article>.from(seedArticles ?? _defaultArticles),
        _sequence = (seedArticles ?? _defaultArticles).length;

  static List<Article> seedData() => List<Article>.from(_defaultArticles);

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

final Author _authorClara = Author(
  id: 'clara-soto',
  name: 'Clara Soto',
  bio: 'Investigative journalist covering climate policy and regulation.',
  avatarUrl: 'https://picsum.photos/seed/clara/200/200',
);

final Author _authorMarcus = Author(
  id: 'marcus-lee',
  name: 'Marcus Lee',
  bio: 'Data reporter focused on urban infrastructure and transit.',
  avatarUrl: 'https://picsum.photos/seed/marcus/200/200',
);

final List<Article> _defaultArticles = [
  Article(
    id: 'mock-article-001',
    title: 'Heat Map 2030: How Cities Will Feel the Next Decade',
    body:
        'New climate models show downtown heat islands intensifying faster than suburban zones, challenging city cooling plans.',
    author: _authorClara,
    coverImageUrl: 'https://picsum.photos/seed/mock-article-001/600/400',
    tags: ['climate', 'cities', 'policy'],
    readingTimeMinutes: 6,
    status: ArticleStatus.published,
    publishedAt: DateTime.utc(2025, 12, 15, 10, 0),
    updatedAt: DateTime.utc(2025, 12, 16, 9, 30),
  ),
  Article(
    id: 'mock-article-002',
    title: 'Inside the Local Desk: Funding Deep Reporting Without Ads',
    body:
        'Three regional newsrooms shared how recurring member support stabilized multi-month investigations without relying on ad cycles.',
    author: _authorMarcus,
    coverImageUrl: 'https://picsum.photos/seed/mock-article-002/600/400',
    tags: ['media', 'business', 'investigations'],
    readingTimeMinutes: 7,
    status: ArticleStatus.published,
    publishedAt: DateTime.utc(2025, 11, 20, 14, 15),
    updatedAt: DateTime.utc(2025, 11, 20, 14, 15),
  ),
  Article(
    id: 'mock-article-003',
    title: 'Night Trains Are Back—But Can Cities Keep Up?',
    body:
        'As overnight rail corridors reopen, the real constraint is station staffing and maintenance, not train availability.',
    author: _authorMarcus,
    coverImageUrl: 'https://picsum.photos/seed/mock-article-003/600/400',
    tags: ['transportation', 'cities'],
    readingTimeMinutes: 5,
    status: ArticleStatus.published,
    publishedAt: DateTime.utc(2025, 10, 5, 8, 45),
    updatedAt: DateTime.utc(2025, 10, 5, 8, 45),
  ),
];
