import '../../domain/entities/article.dart';

class ArticleDraftPayload {
  final Article draftArticle;
  final String? localImagePath;
  final String? selectedSection;

  const ArticleDraftPayload({
    required this.draftArticle,
    this.localImagePath,
    this.selectedSection,
  });
}
