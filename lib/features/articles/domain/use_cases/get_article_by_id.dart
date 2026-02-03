import '../entities/article.dart';
import '../repository/article_repository.dart';

class GetArticleById {
  final ArticleRepository repository;

  const GetArticleById(this.repository);

  Future<Article> call(String id) {
    return repository.getArticleById(id);
  }
}
