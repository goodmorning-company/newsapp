import 'package:bloc/bloc.dart';

import '../../domain/entities/draft_input.dart';
import '../../domain/use_cases/improve_draft_with_ai.dart';
import 'editorial_ai_state.dart';

class EditorialAiCubit extends Cubit<EditorialAiState> {
  final ImproveDraftWithAi _improveDraft;

  EditorialAiCubit(this._improveDraft) : super(const EditorialAiInitial());

  Future<void> improveDraft(DraftInput input) async {
    emit(const EditorialAiImproving());
    try {
      final result = await _improveDraft(input);
      emit(EditorialAiImproved(result));
    } catch (error) {
      emit(EditorialAiError(error.toString()));
    }
  }
}
