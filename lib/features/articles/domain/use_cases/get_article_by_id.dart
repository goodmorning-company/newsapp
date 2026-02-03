import '../entities/article.dart';
import 'mock_articles.dart';

class GetArticleById {
  const GetArticleById();

  Future<Article> call(String id) async {
    final match = mockArticles.firstWhere(
      (article) => article.id == id,
      orElse: () => throw StateError('Article not found: $id'),
    );
    return match;
  }
}
