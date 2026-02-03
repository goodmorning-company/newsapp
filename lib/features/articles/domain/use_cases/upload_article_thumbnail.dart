import '../repository/media_repository.dart';

class UploadArticleThumbnail {
  final MediaRepository repository;

  const UploadArticleThumbnail(this.repository);

  Future<String> call({
    required String articleId,
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) {
    return repository.uploadArticleThumbnail(
      articleId: articleId,
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
    );
  }
}
