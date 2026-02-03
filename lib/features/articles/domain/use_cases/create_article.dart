import '../entities/article.dart';
import 'mock_articles.dart';

class CreateArticle {
  const CreateArticle();

  Future<void> call(Article article) async {
    final now = DateTime.now().toUtc();
    final stored = article.id.isEmpty
        ? article.copyWith(
            id: 'mock-${now.microsecondsSinceEpoch}',
            publishedAt: article.publishedAt,
            updatedAt: now,
          )
        : article.copyWith(updatedAt: now);
    mockArticles.insert(0, stored);
  }
}
