import '../entities/author.dart';

/// Canonical editorial sections (tags).
const List<String> kEditorialSections = [
  'AI',
  'Tech',
  'Design',
  'Science',
  'Business',
];

/// Canonical default authors available across the app.
const List<Author> kDefaultAuthors = [
  Author(
    id: 'author_ava_thompson',
    name: 'Ava Thompson',
    avatarUrl: 'https://picsum.photos/seed/author_ava_thompson/200/200',
    bio: 'Tech journalist covering AI, cloud, and developer tooling.',
  ),
  Author(
    id: 'author_liam_chen',
    name: 'Liam Chen',
    avatarUrl: 'https://picsum.photos/seed/author_liam_chen/200/200',
    bio: 'Productivity writer exploring workflows and remote teams.',
  ),
  Author(
    id: 'author_sofia_ramirez',
    name: 'Sofia Ramirez',
    avatarUrl: 'https://picsum.photos/seed/author_sofia_ramirez/200/200',
    bio: 'Climate and energy correspondent focused on renewables.',
  ),
  Author(
    id: 'author_hailey_nguyen',
    name: 'Hailey Nguyen',
    avatarUrl: 'https://picsum.photos/seed/author_hailey_nguyen/200/200',
    bio: 'Design editor writing about product systems and accessibility.',
  ),
  Author(
    id: 'author_malik_sorensen',
    name: 'Malik Sorensen',
    avatarUrl: 'https://picsum.photos/seed/author_malik_sorensen/200/200',
    bio: 'Security analyst tracking policy, privacy, and quantum threats.',
  ),
];
