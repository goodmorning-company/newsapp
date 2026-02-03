import 'dart:developer';

import '../../domain/repository/media_repository.dart';

class MediaRepositoryWithFallback implements MediaRepository {
  final MediaRepository primary;
  final MediaRepository fallback;

  const MediaRepositoryWithFallback({
    required this.primary,
    required this.fallback,
  });

  @override
  Future<String> uploadArticleThumbnail({
    required String articleId,
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) async {
    try {
      return await primary.uploadArticleThumbnail(
        articleId: articleId,
        bytes: bytes,
        filename: filename,
        mimeType: mimeType,
      );
    } catch (error, stack) {
      log(
        'MediaRepository fallback: uploadArticleThumbnail($articleId, $filename) -> $error',
        name: 'MediaRepositoryWithFallback',
        error: error,
        stackTrace: stack,
      );
      return fallback.uploadArticleThumbnail(
        articleId: articleId,
        bytes: bytes,
        filename: filename,
        mimeType: mimeType,
      );
    }
  }
}
