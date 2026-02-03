class AuthorDto {
  final String id;
  final String name;
  final String? bio;
  final String? avatarUrl;

  const AuthorDto({
    required this.id,
    required this.name,
    this.bio,
    this.avatarUrl,
  });

  factory AuthorDto.fromJson(Map<String, dynamic> json) {
    return AuthorDto(
      id: json['id'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  factory AuthorDto.fromRawData(Map<String, dynamic> json) =>
      AuthorDto.fromJson(json);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'avatarUrl': avatarUrl,
    };
  }
}
