import 'dart:async';

abstract class MediaRepository {
  Future<String> uploadArticleThumbnail({
    required String articleId,
    required List<int> bytes,
    required String filename,
    required String mimeType,
  });
}
