import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

import 'features/articles/domain/use_cases/create_article.dart';
import 'features/articles/domain/use_cases/get_article_by_id.dart';
import 'features/articles/domain/use_cases/get_articles.dart';
import 'features/articles/presentation/bloc/create/create_article_cubit.dart';
import 'features/articles/presentation/bloc/detail/article_detail_cubit.dart';
import 'features/articles/presentation/bloc/feed/articles_feed_cubit.dart';
import 'features/articles/presentation/screens/article_detail_screen.dart';
import 'features/articles/presentation/screens/articles_feed_screen.dart';
import 'features/articles/presentation/screens/create_article_screen.dart';

import 'config/theme/theme_cubit.dart';

import 'features/articles/data/data_sources/article_remote_data_source.dart';
import 'features/articles/data/repository/article_repository_with_fallback.dart';
import 'features/articles/data/repository/firebase_article_repository.dart';
import 'features/articles/data/repository/mock_article_repository.dart';

import 'features/editorial_ai/data/data_sources/editorial_ai_remote_data_source.dart';
import 'features/editorial_ai/data/repository/editorial_ai_repository_with_fallback.dart';
import 'features/editorial_ai/data/repository/mock_editorial_ai_repository.dart';
import 'features/editorial_ai/data/repository/openai_editorial_ai_repository.dart';
import 'features/editorial_ai/domain/use_cases/improve_draft_with_ai.dart';
import 'features/editorial_ai/presentation/bloc/editorial_ai_cubit.dart';

/// 🔐 Compile-time injected key
const String editorialAiKey = String.fromEnvironment('EDITORIAL_AI_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  dev.log('[dev][bootstrap] App starting', name: 'dev');

  assert(
    editorialAiKey.isNotEmpty,
    'EDITORIAL_AI_KEY is missing. Run flutter with --dart-define=EDITORIAL_AI_KEY=...',
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  dev.log('[dev][firebase] Firebase initialized', name: 'dev');

  if (FirebaseAuth.instance.currentUser == null) {
    dev.log('[dev][auth] No user found, signing in anonymously', name: 'dev');
    await FirebaseAuth.instance.signInAnonymously();
  }

  final user = FirebaseAuth.instance.currentUser;
  dev.log('[dev][auth] Authenticated user uid=${user?.uid}', name: 'dev');

  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  static const _accent = Color(0xFF9B8CFF);
  static const _darkBackground = Color(0xFF0F1115);
  static const _darkSurface = Color(0xFF181B22);
  static const _lightBackground = Color(0xFFF6F7FB);
  static const _lightSurface = Colors.white;

  @override
  Widget build(BuildContext context) {
    dev.log('[dev][di] Building repositories', name: 'dev');

    // --- Articles repositories ---
    final firebaseArticleRepo = FirebaseArticleRepositoryImpl(
      ArticleRemoteDataSource(FirebaseFirestore.instance),
    );
    final mockArticleRepo = MockArticleRepositoryImpl();
    final articleRepository = ArticleRepositoryWithFallback(
      primary: firebaseArticleRepo,
      fallback: mockArticleRepo,
    );

    // --- Editorial AI repositories ---
    final editorialAiRemote = EditorialAiRemoteDataSource(
      apiKey: editorialAiKey,
    );
    final editorialAiPrimary = OpenAiEditorialAiRepository(
      remote: editorialAiRemote,
    );
    final editorialAiFallback = MockEditorialAiRepository();
    final editorialAiRepository = EditorialAiRepositoryWithFallback(
      primary: editorialAiPrimary,
      fallback: editorialAiFallback,
    );
    final improveDraftWithAi = ImproveDraftWithAi(editorialAiRepository);

    dev.log('[dev][di] Repositories ready', name: 'dev');

    return MultiRepositoryProvider(
      providers: [RepositoryProvider.value(value: articleRepository)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(
            create: (_) =>
                ArticlesFeedCubit(GetArticles(articleRepository))..load(),
          ),
          BlocProvider(
            create: (_) => CreateArticleCubit(
              createArticle: CreateArticle(articleRepository),
            ),
          ),
          BlocProvider(create: (_) => EditorialAiCubit(improveDraftWithAi)),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (_, themeState) => MaterialApp(
            title: 'High-Impact News',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeState.themeMode,
            debugShowCheckedModeBanner: false,
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
                  builder: (context) => BlocProvider(
                    create: (_) =>
                        ArticleDetailCubit(GetArticleById(articleRepository))
                          ..load(id),
                    child: ArticleDetailScreen(articleId: id),
                  ),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  ThemeData _baseTheme(ColorScheme scheme, Color surface, Color background) {
    final textTheme = Typography.englishLike2021.apply(
      fontFamily: 'Inter',
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: textTheme.copyWith(
        headlineMedium: textTheme.headlineMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(color: scheme.onSurface),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const scheme = ColorScheme.dark(
      primary: _accent,
      surface: _darkSurface,
      onSurface: Color(0xFFE8EAF0),
    );
    return _baseTheme(scheme, _darkSurface, _darkBackground);
  }

  ThemeData _buildLightTheme() {
    const scheme = ColorScheme.light(
      primary: _accent,
      surface: _lightSurface,
      onSurface: Color(0xFF1A1D23),
    );
    return _baseTheme(scheme, _lightSurface, _lightBackground);
  }
}
