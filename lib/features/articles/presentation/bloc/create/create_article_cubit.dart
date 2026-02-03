import 'package:bloc/bloc.dart';

import '../../../domain/entities/article.dart';
import '../../../domain/use_cases/create_article.dart';
import 'create_article_state.dart';

class CreateArticleCubit extends Cubit<CreateArticleState> {
  final CreateArticle _createArticle;

  CreateArticleCubit({
    required CreateArticle createArticle,
  })  : _createArticle = createArticle,
        super(const CreateArticleIdle());

  Future<void> submit(Article article) async {
    emit(const CreateArticleSubmitting());
    try {
      await _createArticle(article);
      emit(CreateArticleSuccess(article));
    } catch (error) {
      emit(CreateArticleError(error.toString()));
    }
  }

  void reset() {
    emit(const CreateArticleIdle());
  }
}
