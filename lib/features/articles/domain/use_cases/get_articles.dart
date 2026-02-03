import '../entities/article.dart';
import 'mock_articles.dart';

class GetArticles {
  const GetArticles();

  Future<List<Article>> call({int? limit}) async {
    final articles = List<Article>.from(mockArticles);
    if (limit == null || limit >= articles.length) {
      return articles;
    }
    return articles.take(limit).toList();
  }
}
