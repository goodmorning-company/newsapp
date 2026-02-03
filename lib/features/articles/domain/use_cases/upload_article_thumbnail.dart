class UploadArticleThumbnail {
  const UploadArticleThumbnail();

  Future<String> call({
    required String articleId,
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) async {
    final safeId = articleId.isEmpty ? 'placeholder' : articleId;
    final safeName = filename.isEmpty ? 'thumbnail.jpg' : filename;
    return 'https://cdn.mocknews.com/articles/$safeId/$safeName';
  }
}
