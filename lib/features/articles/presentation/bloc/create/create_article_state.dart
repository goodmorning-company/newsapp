import 'package:meta/meta.dart';

import '../../../domain/entities/article.dart';

@immutable
sealed class CreateArticleState {
  const CreateArticleState();
}

final class CreateArticleIdle extends CreateArticleState {
  const CreateArticleIdle();
}

final class CreateArticleSubmitting extends CreateArticleState {
  const CreateArticleSubmitting();
}

final class CreateArticleSuccess extends CreateArticleState {
  final Article article;

  const CreateArticleSuccess(this.article);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CreateArticleSuccess && other.article == article);
  }

  @override
  int get hashCode => article.hashCode;
}

final class CreateArticleError extends CreateArticleState {
  final String message;

  const CreateArticleError(this.message);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CreateArticleError && other.message == message);
  }

  @override
  int get hashCode => message.hashCode;
}
