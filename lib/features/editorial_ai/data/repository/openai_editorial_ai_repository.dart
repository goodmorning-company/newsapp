import '../../domain/entities/draft_input.dart';
import '../../domain/entities/improved_draft.dart';
import '../../domain/repository/editorial_ai_repository.dart';
import '../data_sources/editorial_ai_remote_data_source.dart';

class OpenAiEditorialAiRepository implements EditorialAiRepository {
  final EditorialAiRemoteDataSource remote;

  const OpenAiEditorialAiRepository({required this.remote});

  @override
  Future<ImprovedDraft> improveDraft(DraftInput input) {
    return remote.improveDraft(input);
  }
}
