import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
    final firebaseArticleRepo = FirebaseArticleRepositoryImpl(
      ArticleRemoteDataSource(FirebaseFirestore.instance),
    );
    final mockArticleRepo = MockArticleRepositoryImpl();
    final articleRepository = ArticleRepositoryWithFallback(
      primary: firebaseArticleRepo,
      fallback: mockArticleRepo,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: articleRepository),
      ],
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
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (_, themeState) => MaterialApp(
            title: 'High-Impact News',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeState.themeMode,
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
                    create: (_) => ArticleDetailCubit(
                      GetArticleById(articleRepository),
                    )..load(id),
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
    final textTheme = Typography.englishLike2021.apply(fontFamily: 'Inter');
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: 'Inter',
      fontFamilyFallback: const [
        'SF Pro Display',
        'SF Pro Text',
        'Geist',
        'Segoe UI',
        'Roboto',
      ],
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 3,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 10,
        splashColor: Colors.white.withValues(alpha: 0.14),
        focusColor: _accent.withValues(alpha: 0.16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _accent.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: textTheme.labelSmall?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      textTheme: textTheme.copyWith(
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: scheme.onSurface,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: scheme.onSurface,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: scheme.onSurface,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(height: 1.5),
        bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.5),
        bodySmall: textTheme.bodySmall?.copyWith(height: 1.35),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      dividerColor: Colors.white.withValues(alpha: 0.06),
      visualDensity: VisualDensity.standard,
    );
  }

  ThemeData _buildDarkTheme() {
    final scheme = const ColorScheme.dark(
      primary: _accent,
      secondary: _accent,
      surfaceTint: Colors.transparent,
      surface: _darkSurface,
      onSurface: Color(0xFFE8EAF0),
    );
    return _baseTheme(scheme, _darkSurface, _darkBackground);
  }

  ThemeData _buildLightTheme() {
    final scheme = const ColorScheme.light(
      primary: _accent,
      secondary: _accent,
      surfaceTint: Colors.transparent,
      surface: _lightSurface,
      onSurface: Color(0xFF1A1D23),
    );
    return _baseTheme(scheme, _lightSurface, _lightBackground);
  }
}
