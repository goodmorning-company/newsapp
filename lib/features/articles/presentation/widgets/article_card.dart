import 'package:flutter/material.dart';

import '../../domain/entities/article.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final bool isHero;
  final bool isRead;
  final double progress;
  final VoidCallback? onTap;

  const ArticleCard({
    super.key,
    required this.article,
    this.isHero = false,
    this.isRead = false,
    this.progress = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _InteractiveCard(
      onTap: onTap,
      builder: (pressed) => isHero
          ? _HeroContent(
              article: article,
              progress: progress,
              isPressed: pressed,
            )
          : _StandardContent(
              article: article,
              isRead: isRead,
              progress: progress,
              isPressed: pressed,
            ),
    );
  }
}

class _InteractiveCard extends StatefulWidget {
  final Widget Function(bool isPressed) builder;
  final VoidCallback? onTap;

  const _InteractiveCard({required this.builder, this.onTap});

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(16);
    final accent = theme.colorScheme.primary;
    final surface = theme.cardColor;
    final shadowBase = Colors.black.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.3 : 0.16,
    );

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: borderRadius,
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: shadowBase,
              blurRadius: _pressed ? 12 : 18,
              offset: const Offset(0, 10),
              spreadRadius: -6,
            ),
            BoxShadow(
              color: accent.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.08 : 0.06,
              ),
              blurRadius: 28,
              spreadRadius: -18,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            splashColor: accent.withValues(alpha: 0.08),
            highlightColor: accent.withValues(alpha: 0.04),
            child: widget.builder(_pressed),
          ),
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final Article article;
  final double progress;
  final bool isPressed;

  const _HeroContent({
    required this.article,
    required this.progress,
    required this.isPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final accent = theme.colorScheme.primary;
    final category = article.tags.isNotEmpty ? article.tags.first : 'Featured';
    final avatarUrl =
        article.author.avatarUrl ??
        'https://picsum.photos/seed/${article.author.id}/200/200';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 340,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                scale: isPressed ? 1.02 : 1.0,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _NetworkImage(
                      url:
                          article.coverImageUrl ??
                          'https://picsum.photos/seed/hero-fallback/900/900',
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.12),
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryBadge(
                    label: category,
                    accent: accent,
                    inverted: true,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.title,
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      height: 1.15,
                      letterSpacing: -0.8,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(avatarUrl),
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          article.author.name,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${article.readingTimeMinutes} min',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ProgressBar(
                    progress: progress,
                    accent: accent,
                    background: Colors.white.withValues(alpha: 0.22),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StandardContent extends StatelessWidget {
  final Article article;
  final bool isRead;
  final double progress;
  final bool isPressed;

  const _StandardContent({
    required this.article,
    required this.isRead,
    required this.progress,
    required this.isPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final accent = theme.colorScheme.primary;
    final category = article.tags.isNotEmpty ? article.tags.first : 'Briefing';
    final avatarUrl =
        article.author.avatarUrl ??
        'https://picsum.photos/seed/${article.author.id}/200/200';

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 140,
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      scale: isPressed ? 1.02 : 1.0,
                      child: _NetworkImage(
                        url:
                            article.coverImageUrl ??
                            'https://picsum.photos/seed/fallback/700/900',
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.08),
                            Colors.black.withValues(alpha: 0.22),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CategoryBadge(label: category, accent: accent),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: accent.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${article.readingTimeMinutes} min read',
                      style: textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  article.title,
                  style: textTheme.titleMedium?.copyWith(
                    color: isRead
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.55)
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(avatarUrl),
                      backgroundColor: theme.colorScheme.onSurface.withValues(
                        alpha: 0.06,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        article.author.name,
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.72,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ProgressBar(
                  progress: progress,
                  accent: accent,
                  background: theme.colorScheme.onSurface.withValues(
                    alpha: 0.08,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  final String url;

  const _NetworkImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.08);
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, error, stack) => Container(color: placeholderColor),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(color: placeholderColor);
      },
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  final Color accent;
  final bool inverted;

  const _CategoryBadge({
    required this.label,
    required this.accent,
    this.inverted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = inverted ? Colors.white : theme.colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: inverted
            ? Colors.white.withValues(alpha: 0.18)
            : accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: inverted
              ? Colors.white.withValues(alpha: 0.25)
              : accent.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color accent;
  final Color background;

  const _ProgressBar({
    required this.progress,
    required this.accent,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.05, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * clamped;
        return Container(
          height: 4,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.78)],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
