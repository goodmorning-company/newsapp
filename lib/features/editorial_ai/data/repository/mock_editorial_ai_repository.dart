import 'dart:async';

import '../../domain/entities/draft_input.dart';
import '../../domain/entities/improved_draft.dart';
import '../../domain/repository/editorial_ai_repository.dart';

class MockEditorialAiRepository implements EditorialAiRepository {
  const MockEditorialAiRepository({
    this.latency = const Duration(milliseconds: 120),
  });

  final Duration latency;

  @override
  Future<ImprovedDraft> improveDraft(DraftInput input) async {
    await Future<void>.delayed(latency);
    final normalizedTitle = input.title.trim();
    final improvedTitle = normalizedTitle.isEmpty
        ? 'Untitled Draft'
        : '${normalizedTitle[0].toUpperCase()}${normalizedTitle.substring(1)}';

    final body = input.content.trim();
    final improvedContent = body.isEmpty
        ? '_No content provided._'
        : '''
## $improvedTitle

${body.replaceAll('\n\n', '\n\n').replaceAll('\n', '\n\n')}

— Edited for clarity
'''
              .trim();

    return ImprovedDraft(title: improvedTitle, content: improvedContent);
  }
}
