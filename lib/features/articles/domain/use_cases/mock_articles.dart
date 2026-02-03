import '../entities/article.dart';
import '../entities/author.dart';

final List<Author> mockAuthors = [
  Author(
    id: 'auth_1',
    name: 'Ava Thompson',
    bio: 'Tech journalist covering AI, cloud, and developer tooling.',
    avatarUrl: 'https://picsum.photos/seed/auth_1/200/200',
  ),
  Author(
    id: 'auth_2',
    name: 'Liam Chen',
    bio: 'Productivity writer exploring workflows and remote teams.',
    avatarUrl: 'https://picsum.photos/seed/auth_2/200/200',
  ),
  Author(
    id: 'auth_3',
    name: 'Sofia Ramirez',
    bio: 'Climate and energy correspondent with a focus on renewables.',
    avatarUrl: 'https://picsum.photos/seed/auth_3/200/200',
  ),
];

final List<Article> mockArticles = [
  Article(
    id: 'article-1',
    title: 'AI Is Reshaping the Future of Work',
    body:
        'Enterprises are piloting copilots for every role, shifting focus from task execution to supervision and judgment. Experts warn culture must adapt as fast as the tools.',
    author: mockAuthors[0],
    coverImageUrl: 'https://picsum.photos/seed/article-1/800/600',
    tags: ['AI', 'Work'],
    readingTimeMinutes: 7,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-12T09:00:00Z'),
    updatedAt: DateTime.parse('2026-01-12T09:00:00Z'),
  ),
  Article(
    id: 'article-2',
    title: 'Global Markets React to New Tech Policies',
    body:
        'Regulators in the EU and US coordinated fresh guidance on data exports, sending ripples across cloud providers and fintechs reliant on cross-border flows.',
    author: mockAuthors[1],
    coverImageUrl: 'https://picsum.photos/seed/article-2/800/600',
    tags: ['Policy', 'Markets'],
    readingTimeMinutes: 8,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-11T14:30:00Z'),
    updatedAt: DateTime.parse('2026-01-11T14:30:00Z'),
  ),
  Article(
    id: 'article-3',
    title: 'How Deep Focus Became a Competitive Advantage',
    body:
        'Teams that protect focus hours are outpacing peers on complex projects. Leaders are redesigning calendars, incentivizing async, and measuring flow states.',
    author: mockAuthors[2],
    coverImageUrl: 'https://picsum.photos/seed/article-3/800/600',
    tags: ['Productivity', 'Culture'],
    readingTimeMinutes: 6,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-10T08:45:00Z'),
    updatedAt: DateTime.parse('2026-01-10T08:45:00Z'),
  ),
  Article(
    id: 'article-4',
    title: 'Energy Storage Breakthroughs Explained',
    body:
        'LFP cells now dominate grid-scale storage deployments thanks to safer chemistries and falling prices. We unpack the science behind the acceleration.',
    author: mockAuthors[0],
    coverImageUrl: 'https://picsum.photos/seed/article-4/800/600',
    tags: ['Energy', 'Climate'],
    readingTimeMinutes: 9,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-09T11:10:00Z'),
    updatedAt: DateTime.parse('2026-01-09T11:10:00Z'),
  ),
  Article(
    id: 'article-5',
    title: 'Designing Trust in AI-Powered Products',
    body:
        'Product teams are shipping transparency UIs, model cards, and opt-out controls to keep users in the loop as adaptive features roll out at scale.',
    author: mockAuthors[1],
    coverImageUrl: 'https://picsum.photos/seed/article-5/800/600',
    tags: ['Design', 'AI'],
    readingTimeMinutes: 5,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-08T10:05:00Z'),
    updatedAt: DateTime.parse('2026-01-08T10:05:00Z'),
  ),
  Article(
    id: 'article-6',
    title: 'The Quiet Comeback of Night Trains in Europe',
    body:
        'Rail operators are reviving overnight routes with refurbished sleepers and bundled tickets, targeting climate-conscious travelers avoiding short-haul flights.',
    author: mockAuthors[2],
    coverImageUrl: 'https://picsum.photos/seed/article-6/800/600',
    tags: ['Transport', 'Travel'],
    readingTimeMinutes: 7,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-07T06:40:00Z'),
    updatedAt: DateTime.parse('2026-01-07T06:40:00Z'),
  ),
  Article(
    id: 'article-7',
    title: 'Why Local Newsrooms Are Turning to Memberships',
    body:
        'Investigative desks are testing member-only briefings and transparent budgeting to stabilize funding and reduce reliance on advertising swings.',
    author: mockAuthors[0],
    coverImageUrl: 'https://picsum.photos/seed/article-7/800/600',
    tags: ['Media', 'Business'],
    readingTimeMinutes: 4,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-06T13:20:00Z'),
    updatedAt: DateTime.parse('2026-01-06T13:20:00Z'),
  ),
  Article(
    id: 'article-8',
    title: 'Developers Embrace On-Device AI for Privacy',
    body:
        'Edge-optimized models allow note-taking, transcription, and translation to happen offline, reducing latency and keeping personal data on devices.',
    author: mockAuthors[1],
    coverImageUrl: 'https://picsum.photos/seed/article-8/800/600',
    tags: ['AI', 'Privacy'],
    readingTimeMinutes: 6,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-05T09:55:00Z'),
    updatedAt: DateTime.parse('2026-01-05T09:55:00Z'),
  ),
  Article(
    id: 'article-9',
    title: 'Cities Rethink Heat Resilience Ahead of Summer',
    body:
        'Urban planners are prioritizing shaded corridors, misting hubs, and cool roofs as forecasts point to another record-breaking season.',
    author: mockAuthors[2],
    coverImageUrl: 'https://picsum.photos/seed/article-9/800/600',
    tags: ['Cities', 'Climate'],
    readingTimeMinutes: 5,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-04T07:25:00Z'),
    updatedAt: DateTime.parse('2026-01-04T07:25:00Z'),
  ),
  Article(
    id: 'article-10',
    title: 'Quantum-Safe Encryption Trials Move to Production',
    body:
        'Banks and health networks are piloting hybrid key exchange to prepare for post-quantum threats, balancing performance with forward secrecy.',
    author: mockAuthors[1],
    coverImageUrl: 'https://picsum.photos/seed/article-10/800/600',
    tags: ['Security', 'Quantum'],
    readingTimeMinutes: 12,
    status: ArticleStatus.published,
    publishedAt: DateTime.parse('2026-01-03T12:00:00Z'),
    updatedAt: DateTime.parse('2026-01-03T12:00:00Z'),
  ),
];
