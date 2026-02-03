import '../entities/article.dart';
import '../repository/article_repository.dart';

class GetArticles {
  final ArticleRepository repository;

  const GetArticles(this.repository);

  Future<List<Article>> call({int? limit}) {
    return repository.getArticles(limit: limit);
  }
}
