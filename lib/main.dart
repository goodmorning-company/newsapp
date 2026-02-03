import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/articles/domain/use_cases/create_article.dart';
import 'features/articles/domain/use_cases/get_article_by_id.dart';
import 'features/articles/domain/use_cases/get_articles.dart';
import 'features/articles/presentation/bloc/create/create_article_cubit.dart';
import 'features/articles/presentation/bloc/detail/article_detail_cubit.dart';
import 'features/articles/presentation/bloc/feed/articles_feed_cubit.dart';
import 'features/articles/presentation/screens/article_detail_screen.dart';
import 'features/articles/presentation/screens/articles_feed_screen.dart';
import 'features/articles/presentation/screens/create_article_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ArticlesFeedCubit(const GetArticles()),
        ),
        BlocProvider(
          create: (_) => ArticleDetailCubit(const GetArticleById()),
        ),
        BlocProvider(
          create: (_) => CreateArticleCubit(
            createArticle: const CreateArticle(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'High-Impact News',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const ArticlesFeedScreen(),
          '/create': (_) => const CreateArticleScreen(),
        },
        onGenerateRoute: (settings) {
          final uri = Uri.parse(settings.name ?? '');
          if (uri.pathSegments.length == 2 &&
              uri.pathSegments.first == 'article') {
            final id = uri.pathSegments[1];
            return MaterialPageRoute(
              builder: (_) => ArticleDetailScreen(articleId: id),
            );
          }
          return null;
        },
      ),
    );
  }
}
