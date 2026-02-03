import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/article.dart';
import '../../domain/entities/author.dart';
import '../../domain/use_cases/create_article.dart';
import '../bloc/create/create_article_cubit.dart';
import '../bloc/create/create_article_state.dart';

class CreateArticleScreen extends StatelessWidget {
  const CreateArticleScreen({super.key});

  Article _mockArticle() {
    final now = DateTime.now().toUtc();
    return Article(
      id: '',
      title: 'New Mock Article',
      body: 'This is a placeholder body for a newly created mock article.',
      author: const Author(
        id: 'author_mock',
        name: 'Mock Author',
      ),
      coverImageUrl: 'https://picsum.photos/seed/create-default/600/400',
      tags: const ['mock', 'draft'],
      readingTimeMinutes: 4,
      status: ArticleStatus.draft,
      publishedAt: now,
      updatedAt: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateArticleCubit(createArticle: const CreateArticle()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Story'),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: BlocConsumer<CreateArticleCubit, CreateArticleState>(
            listener: (context, state) {
              if (state is CreateArticleSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Article created')),
                );
                Navigator.pop(context);
              }
              if (state is CreateArticleError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.message}')),
                );
              }
            },
            builder: (context, state) {
              final isSubmitting = state is CreateArticleSubmitting;
              final accent = Theme.of(context).colorScheme.primary;
              final surface = Theme.of(context).cardColor;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Write your title here...',
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
                      disabledBorder: OutlineInputBorder(
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent.withValues(alpha: 0.14),
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Attach Image'),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    enabled: false,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Add article here...',
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
                      disabledBorder: OutlineInputBorder(
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
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () {
                              context
                                  .read<CreateArticleCubit>()
                                  .submit(_mockArticle());
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
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
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Publish Article'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
