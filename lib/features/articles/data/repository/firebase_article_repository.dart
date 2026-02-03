import '../../domain/entities/article.dart';
import '../../domain/entities/author.dart';
import '../../domain/repository/article_repository.dart';
import '../data_sources/article_remote_data_source.dart';
import '../models/article_dto.dart';
import '../models/author_dto.dart';

class FirebaseArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource _remote;

  FirebaseArticleRepositoryImpl(ArticleRemoteDataSource remote)
      : _remote = remote;

  @override
  Future<List<Article>> getArticles({int? limit}) async {
    final dtos = await _remote.fetchLatest(limit: limit);
    return dtos.map(_mapToDomain).toList();
  }

  @override
  Future<Article> getArticleById(String id) async {
    final dto = await _remote.fetchById(id);
    if (dto == null) {
      throw StateError('Article not found for id $id');
    }
    return _mapToDomain(dto);
  }

  @override
  Future<void> createArticle(Article article) async {
    final dto = _mapToDto(article);
    await _remote.createArticle(dto);
  }

  Article _mapToDomain(ArticleDto dto) {
    final status = dto.status.toLowerCase() == 'published'
        ? ArticleStatus.published
        : ArticleStatus.draft;
    return Article(
      id: dto.id,
      title: dto.title,
      body: dto.content,
      author: _mapAuthorToDomain(dto.author),
      coverImageUrl: dto.thumbnailUrl,
      tags: dto.tags,
      readingTimeMinutes: dto.readingTimeMinutes,
      status: status,
      publishedAt: dto.publishedAt,
      updatedAt: dto.updatedAt,
    );
  }

  Author _mapAuthorToDomain(AuthorDto dto) {
    return Author(
      id: dto.id,
      name: dto.name,
      bio: dto.bio,
      avatarUrl: dto.avatarUrl,
    );
  }

  ArticleDto _mapToDto(Article article) {
    return ArticleDto(
      id: article.id,
      title: article.title,
      content: article.body,
      author: _mapAuthorToDto(article.author),
      thumbnailUrl: article.coverImageUrl,
      tags: List<String>.from(article.tags),
      readingTimeMinutes: article.readingTimeMinutes,
      status: article.status.name,
      publishedAt: article.publishedAt,
      updatedAt: article.updatedAt,
    );
  }

  AuthorDto _mapAuthorToDto(Author author) {
    return AuthorDto(
      id: author.id,
      name: author.name,
      bio: author.bio,
      avatarUrl: author.avatarUrl,
    );
  }
}
