import 'dart:developer' as dev;

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
    dev.log(
      'submit start | id=${article.id} title=${article.title} coverImageUrl=${article.coverImageUrl}',
      name: 'publish.cubit',
    );
    emit(const CreateArticleSubmitting());
    try {
      dev.log('repository.create start', name: 'publish.cubit');
      await _createArticle(article);
      dev.log(
        'submit success | id=${article.id}',
        name: 'publish.cubit',
      );
      emit(CreateArticleSuccess(article));
    } catch (error, stack) {
      dev.log(
        'submit error | $error',
        name: 'publish.cubit',
        error: error,
        stackTrace: stack,
      );
      emit(CreateArticleError(error.toString()));
    }
  }

  void reset() {
    emit(const CreateArticleIdle());
  }
}
