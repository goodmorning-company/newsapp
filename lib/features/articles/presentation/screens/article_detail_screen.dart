import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../domain/entities/article.dart';
import '../../../editorial_ai/domain/entities/draft_input.dart';
import '../../../editorial_ai/domain/entities/improved_draft.dart';
import '../../../editorial_ai/presentation/bloc/editorial_ai_cubit.dart';
import '../../../editorial_ai/presentation/bloc/editorial_ai_state.dart';
import '../bloc/detail/article_detail_cubit.dart';
import '../bloc/detail/article_detail_state.dart';
import '../models/article_draft_payload.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String? articleId;
  final Article? previewArticle;
  final bool isPreview;

  const ArticleDetailScreen({
    super.key,
    this.articleId,
    this.previewArticle,
    this.isPreview = false,
  }) : assert(isPreview ? previewArticle != null : articleId != null);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  Article? _previewDraft;
  String? _cachedTitle;
  String? _cachedBody;
  bool _aiApplied = false;

  @override
  void initState() {
    super.initState();
    if (widget.isPreview) {
      _previewDraft = widget.previewArticle;
      log('Preview opened', name: 'preview');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('Story'),
        automaticallyImplyLeading: !widget.isPreview,
      ),
      body: widget.isPreview
          ? _buildPreviewBody(context)
          : BlocBuilder<ArticleDetailCubit, ArticleDetailState>(
              builder: (context, state) {
                return switch (state) {
                  ArticleDetailLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ArticleDetailLoaded(:final article) =>
                    _buildArticleView(context, article, isPreview: false),
                  ArticleDetailError(:final message) => Center(
                      child: Text('Error: $message'),
                    ),
                  ArticleDetailNotFound() => const Center(
                      child: Text('Article not found'),
                    ),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
      bottomNavigationBar:
          widget.isPreview
              ? BlocBuilder<EditorialAiCubit, EditorialAiState>(
                  builder: (context, aiState) =>
                      _buildPreviewActions(context, aiState),
                )
              : null,
    );

    if (!widget.isPreview) {
      return scaffold;
    }

    return BlocListener<EditorialAiCubit, EditorialAiState>(
      listener: (context, aiState) {
        if (aiState is EditorialAiImproved) {
          _applyAiDraft(aiState.draft);
        } else if (aiState is EditorialAiError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(aiState.message)));
        }
      },
      child: scaffold,
    );
  }

  DraftInput _buildDraftInput(Article article) {
    return DraftInput(title: article.title, content: article.body);
  }

  void _improveWithAI() {
    final article = _previewDraft ?? widget.previewArticle;
    if (article == null) return;
    _cachedTitle = article.title;
    _cachedBody = article.body;
    context.read<EditorialAiCubit>().improveDraft(_buildDraftInput(article));
  }

  void _applyAiDraft(ImprovedDraft draft) {
    final article = _previewDraft ?? widget.previewArticle;
    if (article == null) return;
    final updatedBody = draft.content;
    setState(() {
      _previewDraft = article.copyWith(
        title: draft.title,
        body: updatedBody,
        summary: _buildSummary(updatedBody),
        readingTimeMinutes: _estimateReadingTime(updatedBody),
        updatedAt: DateTime.now().toUtc(),
      );
      _aiApplied = true;
    });
  }

  void _discardAiChanges() {
    final article = _previewDraft ?? widget.previewArticle;
    if (article == null) return;
    final restoredTitle = _cachedTitle ?? article.title;
    final restoredBody = _cachedBody ?? article.body;
    setState(() {
      _previewDraft = article.copyWith(
        title: restoredTitle,
        body: restoredBody,
        summary: _buildSummary(restoredBody),
        readingTimeMinutes: _estimateReadingTime(restoredBody),
        updatedAt: DateTime.now().toUtc(),
      );
      _cachedTitle = null;
      _cachedBody = null;
      _aiApplied = false;
    });
  }

  Widget _buildPreviewBody(BuildContext context) {
    final article = _previewDraft ?? widget.previewArticle;
    if (article == null) {
      return const Center(child: Text('Preview unavailable'));
    }
    return _buildArticleView(context, article, isPreview: true);
  }

  Widget _buildArticleView(
    BuildContext context,
    Article article, {
    required bool isPreview,
  }) {
    final bottomPadding = isPreview ? 120.0 : 28.0;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              SizedBox(
                height: 260,
                width: double.infinity,
                child: _buildCoverImage(article, isPreview: isPreview),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        article.author.avatarUrl ??
                            'https://picsum.photos/seed/${article.author.id}/200/200',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.author.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            '${_formatDate(article.publishedAt)} · ${article.readingTimeMinutes} min read',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        (article.tags.isNotEmpty ? article.tags.first : 'Feature')
                            .toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          article.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
        ),
        const SizedBox(height: 12),
        Divider(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.08),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: MarkdownBody(
            data: article.body,
            styleSheet: _markdownStyle(context),
            softLineBreak: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCoverImage(Article article, {required bool isPreview}) {
    final coverUrl = article.coverImageUrl;
    final fallback =
        'https://picsum.photos/seed/detail-fallback/900/600';
    if (isPreview &&
        coverUrl != null &&
        coverUrl.isNotEmpty &&
        !_isRemoteUrl(coverUrl)) {
      return Image.file(
        File(coverUrl),
        fit: BoxFit.cover,
        color: Colors.black.withValues(alpha: 0.1),
        colorBlendMode: BlendMode.darken,
        errorBuilder: (context, error, stack) =>
            Container(color: Colors.black12),
      );
    }
    return Image.network(
      (coverUrl == null || coverUrl.isEmpty) ? fallback : coverUrl,
      fit: BoxFit.cover,
      color: Colors.black.withValues(alpha: 0.1),
      colorBlendMode: BlendMode.darken,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(color: Colors.black12);
      },
      errorBuilder: (context, error, stack) => Container(color: Colors.black12),
    );
  }

  bool _isRemoteUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return uri.isScheme('http') || uri.isScheme('https');
  }

  Widget _buildPreviewActions(
    BuildContext context,
    EditorialAiState aiState,
  ) {
    final article = _previewDraft ?? widget.previewArticle;
    if (article == null) return const SizedBox.shrink();
    final accent = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).cardColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isAiWorking = aiState is EditorialAiImproving;
    final aiLabel = isAiWorking
        ? 'Improving…'
        : (_aiApplied ? 'Discard AI changes' : 'Improve with AI');
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, -6),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: onSurface.withValues(alpha: 0.08),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  log('Back pressed', name: 'preview');
                  Navigator.pop(context, _buildDraftPayload(article));
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: isAiWorking
                    ? null
                    : (_aiApplied ? _discardAiChanges : _improveWithAI),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent.withValues(alpha: 0.16),
                  foregroundColor: onSurface,
                  elevation: 0,
                ),
                child: Text(aiLabel),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  log('PREVIEW → publish tapped', name: 'preview');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Publish'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ArticleDraftPayload _buildDraftPayload(Article article) {
    return ArticleDraftPayload(
      draftArticle: article,
      localImagePath: article.coverImageUrl,
      selectedSection: article.tags.isNotEmpty ? article.tags.first : null,
    );
  }

  int _estimateReadingTime(String text) {
    final words = text.trim().split(RegExp(r'\s+')).length;
    return (words / 200).clamp(1, 15).ceil();
  }

  String _buildSummary(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return '';
    const minChars = 140;
    const maxChars = 200;
    if (normalized.length <= maxChars) return normalized;
    final cut = normalized.substring(0, maxChars);
    final lastSpace = cut.lastIndexOf(' ');
    final safeCut = lastSpace >= minChars ? cut.substring(0, lastSpace) : cut;
    return safeCut.trim();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  MarkdownStyleSheet _markdownStyle(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final onSurface = theme.colorScheme.onSurface;
    final accent = theme.colorScheme.primary;
    final quoteBg =
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final quoteBorder = accent.withValues(alpha: 0.35);

    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      blockSpacing: 18,
      p: textTheme.bodyLarge?.copyWith(
        height: 1.7,
        color: onSurface,
      ),
      pPadding: const EdgeInsets.only(bottom: 14),
      h2: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: onSurface,
      ),
      h2Padding: const EdgeInsets.only(top: 22, bottom: 10),
      h3: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: onSurface,
      ),
      h3Padding: const EdgeInsets.only(top: 18, bottom: 8),
      strong: textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      em: textTheme.bodyLarge?.copyWith(
        fontStyle: FontStyle.italic,
        color: onSurface,
      ),
      blockquoteDecoration: BoxDecoration(
        color: quoteBg,
        border: Border(left: BorderSide(color: quoteBorder, width: 3)),
        borderRadius: BorderRadius.circular(10),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      blockquote: textTheme.titleMedium?.copyWith(
        height: 1.5,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: onSurface.withValues(alpha: 0.12), width: 1),
        ),
      ),
      listBullet: textTheme.bodyLarge?.copyWith(color: onSurface),
      listBulletPadding: const EdgeInsets.only(right: 8),
    );
  }
}
