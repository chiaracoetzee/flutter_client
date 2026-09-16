class PublicPersona {
  const PublicPersona({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.systemName,
    this.pronouns,
    this.color,
    this.bio,
    this.visibility,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String? systemName;
  final String? pronouns;
  final int? color;
  final String? bio;
  final String? visibility;

  factory PublicPersona.fromJson(Map<String, dynamic> json) {
    return PublicPersona(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? json['avatar'] as String?,
      systemName:
          json['system_name'] as String? ?? json['display_tag_text'] as String?,
      pronouns: json['pronouns'] as String?,
      color: (json['color'] as num?)?.toInt(),
      bio: json['bio'] as String?,
      visibility: json['visibility'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (systemName != null) 'system_name': systemName,
      if (pronouns != null) 'pronouns': pronouns,
      if (color != null) 'color': color,
      if (bio != null) 'bio': bio,
      if (visibility != null) 'visibility': visibility,
    };
  }

  PublicPersona copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? systemName,
    String? pronouns,
    int? color,
    String? bio,
    String? visibility,
  }) {
    return PublicPersona(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      systemName: systemName ?? this.systemName,
      pronouns: pronouns ?? this.pronouns,
      color: color ?? this.color,
      bio: bio ?? this.bio,
      visibility: visibility ?? this.visibility,
    );
  }
}
