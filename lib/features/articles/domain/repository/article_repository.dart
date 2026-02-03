import '../entities/article.dart';

abstract class ArticleRepository {
  Future<List<Article>> getArticles({int? limit});
  Future<Article> getArticleById(String id);
  Future<void> createArticle(Article article);
}
