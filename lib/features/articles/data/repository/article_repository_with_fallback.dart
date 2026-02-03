import 'dart:developer' as dev;

import '../../domain/entities/article.dart';
import '../../domain/repository/article_repository.dart';

class ArticleRepositoryWithFallback implements ArticleRepository {
  final ArticleRepository primary;
  final ArticleRepository fallback;

  const ArticleRepositoryWithFallback({
    required this.primary,
    required this.fallback,
  });

  @override
  Future<List<Article>> getArticles({int? limit}) async {
    try {
      dev.log('Firebase → getArticles(limit=$limit)', name: 'ArticleRepo');
      final primaryResult = await primary.getArticles(limit: limit);
      if (primaryResult.isNotEmpty) {
        dev.log('Firebase OK: ${primaryResult.length} articles',
            name: 'ArticleRepo');
        return primaryResult;
      }
      dev.log('Firebase OK but EMPTY: fallback to mock', name: 'ArticleRepo');
    } catch (error, stack) {
      dev.log('Firebase ERROR getArticles -> $error',
          name: 'ArticleRepo', error: error, stackTrace: stack);
    }
    final fallbackResult = await fallback.getArticles(limit: limit);
    dev.log('MOCK source: ${fallbackResult.length} articles',
        name: 'ArticleRepo');
    return fallbackResult;
  }

  @override
  Future<Article> getArticleById(String id) async {
    try {
      dev.log('Firebase → getArticleById($id)', name: 'ArticleRepo');
      final article = await primary.getArticleById(id);
      dev.log('Firebase OK: resolved $id', name: 'ArticleRepo');
      return article;
    } catch (error, stack) {
      dev.log('Firebase ERROR getArticleById($id) -> $error',
          name: 'ArticleRepo', error: error, stackTrace: stack);
    }
    final fallbackArticle = await fallback.getArticleById(id);
    dev.log('MOCK source: resolved $id', name: 'ArticleRepo');
    return fallbackArticle;
  }

  @override
  Future<void> createArticle(Article article) async {
    try {
      dev.log('Firebase → createArticle(${article.id})', name: 'ArticleRepo');
      await primary.createArticle(article);
      dev.log('Firebase createArticle OK (${article.id})', name: 'ArticleRepo');
    } catch (error, stack) {
      dev.log('Firebase ERROR createArticle -> $error',
          name: 'ArticleRepo', error: error, stackTrace: stack);
      await fallback.createArticle(article);
      dev.log('MOCK createArticle (${article.id})', name: 'ArticleRepo');
    }
  }
}
