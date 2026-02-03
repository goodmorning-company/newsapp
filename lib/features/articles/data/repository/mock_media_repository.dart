import '../../domain/repository/media_repository.dart';

class MockMediaRepositoryImpl implements MediaRepository {
  final String baseUrl;

  const MockMediaRepositoryImpl({
    this.baseUrl = 'https://cdn.mocknews.com/articles',
  });

  @override
  Future<String> uploadArticleThumbnail({
    required String articleId,
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) async {
    final safeId = articleId.isEmpty ? 'placeholder' : articleId;
    final safeName = filename.isEmpty ? 'thumbnail.jpg' : filename;
    return '$baseUrl/$safeId/$safeName';
  }
}
