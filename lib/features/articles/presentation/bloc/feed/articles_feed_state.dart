import 'package:meta/meta.dart';

import '../../../domain/entities/article.dart';

@immutable
sealed class ArticlesFeedState {
  const ArticlesFeedState();
}

final class ArticlesFeedInitial extends ArticlesFeedState {
  const ArticlesFeedInitial();
}

final class ArticlesFeedLoading extends ArticlesFeedState {
  const ArticlesFeedLoading();
}

final class ArticlesFeedSuccess extends ArticlesFeedState {
  final List<Article> articles;

  const ArticlesFeedSuccess(this.articles);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ArticlesFeedSuccess &&
            _listEquals(other.articles, articles));
  }

  @override
  int get hashCode => Object.hashAll(articles);
}

final class ArticlesFeedError extends ArticlesFeedState {
  final String message;

  const ArticlesFeedError(this.message);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ArticlesFeedError && other.message == message);
  }

  @override
  int get hashCode => message.hashCode;
}

bool _listEquals(List<Object?> a, List<Object?> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
