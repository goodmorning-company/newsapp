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
  }) {
    return _remote.uploadArticleThumbnail(
      articleId: articleId,
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
    );
  }
}
