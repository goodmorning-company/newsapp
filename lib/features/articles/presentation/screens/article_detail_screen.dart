import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/get_article_by_id.dart';
import '../bloc/detail/article_detail_cubit.dart';
import '../bloc/detail/article_detail_state.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ArticleDetailCubit(const GetArticleById())..load(articleId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Article Detail'),
        ),
        body: BlocBuilder<ArticleDetailCubit, ArticleDetailState>(
          builder: (context, state) {
            return switch (state) {
              ArticleDetailLoading() =>
                const Center(child: CircularProgressIndicator()),
              ArticleDetailLoaded(:final article) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'by ${article.author.name}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          article.coverImageUrl ??
                              'https://picsum.photos/seed/detail-fallback/600/400',
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              height: 220,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.image, color: Colors.grey),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stack) {
                            return Container(
                              height: 220,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.broken_image,
                                    color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x11000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text(
                          article.body,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ArticleDetailError(:final message) =>
                Center(child: Text('Error: $message')),
              ArticleDetailNotFound() =>
                const Center(child: Text('Article not found')),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}
