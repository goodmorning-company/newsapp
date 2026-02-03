import '../../domain/entities/draft_input.dart';
import '../../domain/entities/improved_draft.dart';
import '../../domain/repository/editorial_ai_repository.dart';
import 'dart:developer';

class EditorialAiRepositoryWithFallback implements EditorialAiRepository {
  final EditorialAiRepository primary;
  final EditorialAiRepository fallback;

  const EditorialAiRepositoryWithFallback({
    required this.primary,
    required this.fallback,
  });

  @override
  Future<ImprovedDraft> improveDraft(DraftInput input) async {
    try {
      final result = await primary.improveDraft(input);
      if (_isValid(result)) {
        return result;
      }
      log('EDITORIAL_AI → FALLBACK → using mock AI improvement',
          name: 'editorial_ai');
    } catch (_) {
      // ignore and use fallback
      log('EDITORIAL_AI → FALLBACK → using mock AI improvement',
          name: 'editorial_ai');
    }
    return fallback.improveDraft(input);
  }

  bool _isValid(ImprovedDraft draft) {
    return draft.title.trim().isNotEmpty && draft.content.trim().isNotEmpty;
  }
}
