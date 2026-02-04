import 'package:bloc/bloc.dart';

import '../../../domain/use_cases/get_articles.dart';
import 'articles_feed_state.dart';

class ArticlesFeedCubit extends Cubit<ArticlesFeedState> {
  final GetArticles _getArticles;

  ArticlesFeedCubit(this._getArticles)
      : super(const ArticlesFeedInitial());

  Future<void> load({int? limit, bool forceRefresh = false}) async {
    emit(const ArticlesFeedLoading());
    try {
      final articles = await _getArticles(limit: limit);
      emit(ArticlesFeedSuccess(articles));
    } catch (error) {
      emit(ArticlesFeedError(error.toString()));
    }
  }
}
