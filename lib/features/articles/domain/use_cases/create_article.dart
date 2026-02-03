import '../entities/article.dart';
import '../repository/article_repository.dart';

class CreateArticle {
  final ArticleRepository repository;

  const CreateArticle(this.repository);

  Future<void> call(Article article) async {
    await repository.createArticle(article);
  }
}
