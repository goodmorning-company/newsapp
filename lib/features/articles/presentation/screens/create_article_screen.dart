import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/constants/editorial_defaults.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/author.dart';

import '../bloc/create/create_article_cubit.dart';
import '../bloc/create/create_article_state.dart';
import '../bloc/feed/articles_feed_cubit.dart';
import '../models/article_draft_payload.dart';
import 'article_detail_screen.dart';

class CreateArticleScreen extends StatefulWidget {
  const CreateArticleScreen({super.key});

  @override
  State<CreateArticleScreen> createState() => _CreateArticleScreenState();
}

class _CreateArticleScreenState extends State<CreateArticleScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late final Author _author;

  String? _selectedSection;
  XFile? _selectedImage;
  ArticleDraftPayload? _lastDraftPayload;
  static const int _titleMin = 10;
  static const int _titleMax = 140;
  static const int _bodyMin = 200;
  static const int _bodyMax = 4000;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _author = (kDefaultAuthors.toList()..shuffle()).first;
  }

  bool get _isValid =>
      _titleController.text.trim().length >= _titleMin &&
      _titleController.text.trim().length <= _titleMax &&
      _bodyController.text.trim().length >= _bodyMin &&
      _bodyController.text.trim().length <= _bodyMax &&
      _selectedSection != null &&
      _selectedImage != null;

  String get _titleCount =>
      '${_titleController.text.trim().length} / $_titleMax (min $_titleMin)';

  String get _bodyCount =>
      '${_bodyController.text.trim().length} / $_bodyMax (min $_bodyMin)';

  bool get _isTitleAtMax => _titleController.text.trim().length >= _titleMax;
  bool get _isBodyAtMax => _bodyController.text.trim().length >= _bodyMax;

  Article _buildArticle() {
    final now = DateTime.now().toUtc();
    return Article(
      id: '',
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      summary: _buildSummary(_bodyController.text),
      author: _author,
      coverImageUrl: _selectedImage?.path,
      tags: [_selectedSection ?? kEditorialSections.first],
      readingTimeMinutes: _estimateReadingTime(_bodyController.text),
      status: ArticleStatus.draft,
      publishedAt: now,
      updatedAt: now,
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

  Future<void> _selectCover() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      _selectedImage = picked;
    });
  }

  void _removeCover() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _continueToPreview() async {
    final article = _buildArticle();
    log(
      'Continue pressed (titleLength=${article.title.length}, contentLength=${article.body.length})',
      name: 'preview',
    );
    final payload = ArticleDraftPayload(
      draftArticle: article,
      localImagePath: _selectedImage?.path,
      selectedSection: _selectedSection,
    );
    _lastDraftPayload = payload;

    final result = await Navigator.push<ArticleDraftPayload>(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(
          isPreview: true,
          previewArticle: payload.draftArticle,
        ),
      ),
    );

    if (!mounted || result == null) return;
    final tagFallback = result.draftArticle.tags.isNotEmpty
        ? result.draftArticle.tags.first
        : null;
    final imagePath =
        result.localImagePath ?? result.draftArticle.coverImageUrl;
    setState(() {
      _titleController.text = result.draftArticle.title;
      _bodyController.text = result.draftArticle.body;
      _selectedSection = result.selectedSection ?? tagFallback;
      _selectedImage =
          imagePath == null || imagePath.isEmpty ? null : XFile(imagePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    log('CreateArticleScreen build', name: 'preview');
    final accent = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).cardColor;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('New Story')),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocConsumer<CreateArticleCubit, CreateArticleState>(
            listener: (context, state) {
              if (state is CreateArticleSubmitting) {
                log(
                  'Publish flow start | articleId=${_lastDraftPayload?.draftArticle.id} coverImageUrl=${_lastDraftPayload?.draftArticle.coverImageUrl} localImagePath=${_lastDraftPayload?.localImagePath}',
                  name: 'publish.ui',
                );
              }
              if (state is CreateArticleSuccess) {
                log('[feed.refresh] Triggered', name: 'feed.refresh');
                context.read<ArticlesFeedCubit>().load(forceRefresh: true);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Article created')));
                Navigator.pop(context);
              }
              if (state is CreateArticleError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.message}')),
                );
              }
            },
            builder: (context, createState) {
              final isSubmitting = createState is CreateArticleSubmitting;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  24 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(
                            _author.avatarUrl ?? '',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Story by',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                            Text(
                              _author.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _titleController,
                            maxLength: _titleMax,
                            enabled: !isSubmitting,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Write your title here...',
                              counterText: _titleCount,
                              counterStyle: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: _isTitleAtMax
                                        ? accent
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                  ),
                              filled: true,
                              fillColor: surface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.08),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.08),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _titleController.text.trim().length < _titleMin
                                ? 'Minimum $_titleMin characters required'
                                : '',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedSection,
                            items: kEditorialSections
                                .map(
                                  (section) => DropdownMenuItem(
                                    value: section,
                                    child: Text(section),
                                  ),
                                )
                                .toList(),
                            onChanged: isSubmitting
                                ? null
                                : (value) => setState(() {
                                    _selectedSection = value;
                                  }),
                            decoration: InputDecoration(
                              hintText: 'Select section',
                              filled: true,
                              fillColor: surface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.08),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedImage == null
                                    ? accent.withValues(alpha: 0.14)
                                    : accent.withValues(alpha: 0.18),
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              icon: Icon(
                                _selectedImage == null
                                    ? Icons.photo_camera_outlined
                                    : Icons.check_circle,
                              ),
                              label: Text(
                                _selectedImage == null
                                    ? 'Attach Image'
                                    : 'Image Attached',
                              ),
                              onPressed: isSubmitting ? null : _selectCover,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_selectedImage != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                width: double.infinity,
                                height: 140,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(
                                      File(_selectedImage!.path),
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: InkWell(
                                        onTap: _removeCover,
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.5,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(6),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          TextField(
                            controller: _bodyController,
                            onChanged: (_) => setState(() {}),
                            maxLength: _bodyMax,
                            maxLines: 6,
                            enabled: !isSubmitting,
                            decoration: InputDecoration(
                              hintText: 'Add article here...',
                              counterText: _bodyCount,
                              counterStyle: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: _isBodyAtMax
                                        ? accent
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                  ),
                              filled: true,
                              fillColor: surface,
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.08),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.08),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _bodyController.text.trim().length < _bodyMin
                                ? 'Minimum $_bodyMin characters required'
                                : '',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isValid
                                ? ''
                                : 'Title, section, body, and image are required.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: !_isValid || isSubmitting
                                      ? null
                                      : () {
                                          log(
                                            'Preview open | titleLen=${_titleController.text.trim().length} bodyLen=${_bodyController.text.trim().length} section=$_selectedSection imagePath=${_selectedImage?.path}',
                                            name: 'publish.ui',
                                          );
                                          _continueToPreview();
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isValid ? accent : surface,
                                    foregroundColor: _isValid
                                        ? Colors.white
                                        : Colors.grey[600],
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: isSubmitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Continue'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    );
            },
          ),
      ),
    );
  }
}
