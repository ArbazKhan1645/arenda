class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.phone,
    this.bio,
    this.location,
    this.joinedAt,
    this.isSuperhost = false,
  });

  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String? phone;
  final String? bio;
  final String? location;
  final DateTime? joinedAt;
  final bool isSuperhost;

  String get firstName => name.split(' ').first;
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return parts.first[0].toUpperCase();
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? phone,
    String? bio,
    String? location,
    DateTime? joinedAt,
    bool? isSuperhost,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      joinedAt: joinedAt ?? this.joinedAt,
      isSuperhost: isSuperhost ?? this.isSuperhost,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserEntity && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
