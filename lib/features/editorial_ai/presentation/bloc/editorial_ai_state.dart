import '../../domain/entities/improved_draft.dart';

sealed class EditorialAiState {
  const EditorialAiState();
}

class EditorialAiInitial extends EditorialAiState {
  const EditorialAiInitial();
}

class EditorialAiImproving extends EditorialAiState {
  const EditorialAiImproving();
}

class EditorialAiImproved extends EditorialAiState {
  final ImprovedDraft draft;

  const EditorialAiImproved(this.draft);
}

class EditorialAiError extends EditorialAiState {
  final String message;

  const EditorialAiError(this.message);
}
