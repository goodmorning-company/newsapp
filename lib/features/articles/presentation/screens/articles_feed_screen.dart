import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/get_articles.dart';
import '../bloc/feed/articles_feed_cubit.dart';
import '../bloc/feed/articles_feed_state.dart';
import '../widgets/article_card.dart';
import '../../../../config/theme/theme_cubit.dart';

class ArticlesFeedScreen extends StatelessWidget {
  const ArticlesFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArticlesFeedCubit(const GetArticles())..load(),
      child: Scaffold(
        appBar: _EditorialAppBar(),
        body: BlocBuilder<ArticlesFeedCubit, ArticlesFeedState>(
          builder: (context, state) {
            if (state is ArticlesFeedLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ArticlesFeedSuccess) {
              final articles = state.articles;
              final topCount = articles.length >= 4 ? 4 : articles.length;
              final topStories = articles.take(topCount).toList();
              final remaining = articles.skip(topCount).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: [
                  const SizedBox(height: 6),
                  Text(
                    'Today',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Top Stories',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 360,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.9),
                      padEnds: false,
                      itemCount: topStories.length,
                      itemBuilder: (context, index) {
                        final article = topStories[index];
                        final progress = (0.22 + index * 0.12).clamp(
                          0.18,
                          0.95,
                        );
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index == topStories.length - 1 ? 0 : 14,
                          ),
                          child: ArticleCard(
                            article: article,
                            isHero: true,
                            isRead: false,
                            progress: progress.toDouble(),
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/article/${article.id}',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Divider(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                  ...remaining.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final article = entry.value;
                    final isRead = idx.isEven;
                    final progress = (0.32 + (idx * 0.14)).clamp(0.18, 0.95);
                    return Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: ArticleCard(
                        article: article,
                        isHero: false,
                        isRead: isRead,
                        progress: progress.toDouble(),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/article/${article.id}',
                        ),
                      ),
                    );
                  }),
                ],
              );
            }
            if (state is ArticlesFeedError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/create'),
            child: const Icon(Icons.add, size: 26),
          ),
        ),
      ),
    );
  }
}

class _EditorialAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = context.watch<ThemeCubit>().state;
    final isDark = themeState.themeMode == ThemeMode.dark;
    return AppBar(
      toolbarHeight: 76,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'High-Impact News',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Morning Edition',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: IconButton(
            key: ValueKey(isDark),
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: isDark
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            onPressed: context.read<ThemeCubit>().toggleTheme,
            splashRadius: 22,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {},
          splashRadius: 22,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
