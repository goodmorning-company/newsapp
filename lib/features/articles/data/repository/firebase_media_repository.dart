import 'dart:developer';

import '../../domain/repository/media_repository.dart';
import '../data_sources/media_remote_data_source.dart';

class FirebaseMediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDataSource _remote;

  FirebaseMediaRepositoryImpl(this._remote);

  @override
  Future<String> uploadArticleThumbnail({
    required String articleId,
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) async {
    final storagePath = '${_remote.basePath}/$articleId/$filename';
    log(
      'Upload start | localPath=$filename storagePath=$storagePath mimeType=$mimeType bytes=${bytes.length}',
      name: 'publish.storage',
    );
    try {
      final url = await _remote.uploadArticleThumbnail(
        articleId: articleId,
        bytes: bytes,
        filename: filename,
        mimeType: mimeType,
      );
      log(
        'Upload success | url=$url',
        name: 'publish.storage',
      );
      return url;
    } catch (error, stack) {
      log(
        'Upload error | $error',
        name: 'publish.storage',
        error: error,
        stackTrace: stack,
      );
      rethrow;
    }
  }
}
