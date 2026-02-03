import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/constants/editorial_defaults.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/author.dart';
import '../../../editorial_ai/domain/entities/draft_input.dart';
import '../../../editorial_ai/domain/entities/improved_draft.dart';
import '../../../editorial_ai/presentation/bloc/editorial_ai_cubit.dart';
import '../../../editorial_ai/presentation/bloc/editorial_ai_state.dart';

import '../bloc/create/create_article_cubit.dart';
import '../bloc/create/create_article_state.dart';

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
  String? _cachedTitle;
  String? _cachedBody;
  bool _aiApplied = false;

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

  bool get _canImproveWithAi =>
      _titleController.text.trim().length >= _titleMin &&
      _bodyController.text.trim().length >= _bodyMin;

  String get _titleCount =>
      '${_titleController.text.trim().length} / $_titleMax (min $_titleMin)';

  String get _bodyCount =>
      '${_bodyController.text.trim().length} / $_bodyMax (min $_bodyMin)';

  bool get _isTitleAtMax => _titleController.text.trim().length >= _titleMax;
  bool get _isBodyAtMax => _bodyController.text.trim().length >= _bodyMax;

  DraftInput _buildDraftInput() {
    return DraftInput(
      title: _titleController.text.trim(),
      content: _bodyController.text.trim(),
    );
  }

  void _improveWithAI() {
    _cachedTitle = _titleController.text;
    _cachedBody = _bodyController.text;
    final input = _buildDraftInput();
    context.read<EditorialAiCubit>().improveDraft(input);
  }

  void _applyAiDraft(ImprovedDraft draft) {
    setState(() {
      _titleController.text = draft.title;
      _bodyController.text = draft.content;
      _aiApplied = true;
    });
  }

  void _discardAiChanges() {
    setState(() {
      _titleController.text = _cachedTitle ?? _titleController.text;
      _bodyController.text = _cachedBody ?? _bodyController.text;
      _cachedTitle = null;
      _cachedBody = null;
      _aiApplied = false;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).cardColor;

    return Scaffold(
      appBar: AppBar(title: const Text('New Story')),
      floatingActionButton: _aiApplied
          ? FloatingActionButton.extended(
              onPressed: _discardAiChanges,
              icon: const Icon(Icons.undo),
              label: const Text('Discard AI changes'),
            )
          : null,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocConsumer<CreateArticleCubit, CreateArticleState>(
          listener: (context, state) {
            if (state is CreateArticleSuccess) {
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
              child: BlocBuilder<EditorialAiCubit, EditorialAiState>(
                builder: (context, aiState) {
                  final isAiWorking = aiState is EditorialAiImproving;
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
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                ),
                                Text(
                                  _author.name,
                                  style: Theme.of(context).textTheme.bodyMedium
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
                          enabled: !isAiWorking && !isSubmitting,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Write your title here...',
                            counterText: _titleCount,
                            counterStyle: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: _isTitleAtMax
                                      ? accent
                                      : Theme.of(context).colorScheme.onSurface
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.08),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.08),
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
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
                          onChanged: isAiWorking || isSubmitting
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.08),
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
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onSurface,
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
                            onPressed: isAiWorking || isSubmitting
                                ? null
                                : _selectCover,
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
                          enabled: !isAiWorking && !isSubmitting,
                          decoration: InputDecoration(
                            hintText: 'Add article here...',
                            counterText: _bodyCount,
                            counterStyle: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: _isBodyAtMax
                                      ? accent
                                      : Theme.of(context).colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                ),
                            filled: true,
                            fillColor: surface,
                            contentPadding: const EdgeInsets.all(16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.08),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.08),
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isValid
                              ? ''
                              : 'Title, section, body, and image are required.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    !_canImproveWithAi ||
                                        isAiWorking ||
                                        isSubmitting
                                    ? null
                                    : _improveWithAI,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      !_canImproveWithAi ||
                                          isAiWorking ||
                                          isSubmitting
                                      ? surface
                                      : accent.withValues(alpha: 0.16),
                                  foregroundColor: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.9),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  isAiWorking
                                      ? 'Improving…'
                                      : 'Improve with AI',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: !_isValid || isSubmitting
                                    ? null
                                    : () {
                                        context
                                            .read<CreateArticleCubit>()
                                            .submit(_buildArticle());
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
                                    : const Text('Publish'),
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
            );
          },
        ),
      ),
    );
  }
}
