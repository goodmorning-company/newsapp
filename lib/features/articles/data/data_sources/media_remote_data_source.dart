import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class MediaRemoteDataSource {
  final FirebaseStorage _storage;
  final String basePath;

  MediaRemoteDataSource(
    FirebaseStorage storage, {
    this.basePath = 'media/articles',
  }) : _storage = storage;

  Future<String> uploadArticleThumbnail({
    required String articleId,
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) async {
    if (articleId.isEmpty) {
      throw ArgumentError.value(articleId, 'articleId', 'cannot be empty');
    }
    if (filename.isEmpty) {
      throw ArgumentError.value(filename, 'filename', 'cannot be empty');
    }

    final ref = _storage.ref().child('$basePath/$articleId/$filename');

    final metadata = SettableMetadata(contentType: mimeType);
    final uploadTask =
        await ref.putData(Uint8List.fromList(bytes), metadata);
    return uploadTask.ref.getDownloadURL();
  }
}
