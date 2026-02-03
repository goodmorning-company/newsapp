import '../entities/draft_input.dart';
import '../entities/improved_draft.dart';
import '../repository/editorial_ai_repository.dart';

class ImproveDraftWithAi {
  final EditorialAiRepository repository;

  const ImproveDraftWithAi(this.repository);

  Future<ImprovedDraft> call(DraftInput input) {
    return repository.improveDraft(input);
  }
}
