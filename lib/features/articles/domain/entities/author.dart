class Author {
  final String id;
  final String name;
  final String? bio;
  final String? avatarUrl;

  const Author({
    required this.id,
    required this.name,
    this.bio,
    this.avatarUrl,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Author &&
            other.id == id &&
            other.name == name &&
            other.bio == bio &&
            other.avatarUrl == avatarUrl);
  }

  @override
  int get hashCode => Object.hash(id, name, bio, avatarUrl);
}
