import 'package:bloc/bloc.dart';

import '../../../domain/use_cases/get_article_by_id.dart';
import 'article_detail_state.dart';

class ArticleDetailCubit extends Cubit<ArticleDetailState> {
  final GetArticleById _getArticleById;

  ArticleDetailCubit(this._getArticleById)
      : super(const ArticleDetailInitial());

  Future<void> load(String id) async {
    emit(const ArticleDetailLoading());
    try {
      final article = await _getArticleById(id);
      emit(ArticleDetailLoaded(article));
    } catch (error) {
      if (error is StateError) {
        emit(const ArticleDetailNotFound());
      } else {
        emit(ArticleDetailError(error.toString()));
      }
    }
  }
}
