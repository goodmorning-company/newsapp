import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/article.dart';
import '../../domain/use_cases/get_articles.dart';
import '../bloc/feed/articles_feed_cubit.dart';
import '../bloc/feed/articles_feed_state.dart';
import '../widgets/article_card.dart';

class ArticlesFeedScreen extends StatelessWidget {
  const ArticlesFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArticlesFeedCubit(const GetArticles())..load(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daily News'),
        ),
        body: BlocBuilder<ArticlesFeedCubit, ArticlesFeedState>(
          builder: (context, state) {
            return switch (state) {
              ArticlesFeedLoading() =>
                const Center(child: CircularProgressIndicator()),
              ArticlesFeedSuccess(:final List<Article> articles) => ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (_, index) => GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/article/${articles[index].id}',
                    ),
                    child: ArticleCard(article: articles[index]),
                  ),
                ),
              ArticlesFeedError(:final message) =>
                Center(child: Text('Error: $message')),
              _ => const SizedBox.shrink(),
            };
          },
        ),
        floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: Colors.purple[100],
          onPressed: () => Navigator.pushNamed(context, '/create'),
          child: const Icon(Icons.add, color: Colors.black87),
        ),
      ),
    );
  }
}
