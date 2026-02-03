import 'package:meta/meta.dart';

import '../../../domain/entities/article.dart';

@immutable
sealed class ArticleDetailState {
  const ArticleDetailState();
}

final class ArticleDetailInitial extends ArticleDetailState {
  const ArticleDetailInitial();
}

final class ArticleDetailLoading extends ArticleDetailState {
  const ArticleDetailLoading();
}

final class ArticleDetailLoaded extends ArticleDetailState {
  final Article article;

  const ArticleDetailLoaded(this.article);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ArticleDetailLoaded && other.article == article);
  }

  @override
  int get hashCode => article.hashCode;
}

final class ArticleDetailNotFound extends ArticleDetailState {
  const ArticleDetailNotFound();
}

final class ArticleDetailError extends ArticleDetailState {
  final String message;

  const ArticleDetailError(this.message);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ArticleDetailError && other.message == message);
  }

  @override
  int get hashCode => message.hashCode;
}
