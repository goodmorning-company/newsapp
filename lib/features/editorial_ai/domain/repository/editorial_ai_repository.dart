import '../entities/draft_input.dart';
import '../entities/improved_draft.dart';

abstract class EditorialAiRepository {
  Future<ImprovedDraft> improveDraft(DraftInput input);
}
