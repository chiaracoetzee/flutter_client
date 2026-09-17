import 'package:fluxer_app/features/profile/domain/persona.dart';

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
    this.autoTagDisabled = false,
    this.personaTags = const [],
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String? systemName;
  final String? pronouns;
  final int? color;
  final String? bio;
  final String? visibility;
  final bool autoTagDisabled;
  final List<PersonaTag> personaTags;

  factory PublicPersona.fromJson(Map<String, dynamic> json) {
    final rawTags = json['persona_tags'] as List<dynamic>? ??
        json['personaTags'] as List<dynamic>? ??
        const [];
    final tags = rawTags
        .map((t) {
          if (t is Map<String, dynamic>) return PersonaTag.fromJson(t);
          if (t is Map) {
            return PersonaTag.fromJson(Map<String, dynamic>.from(t));
          }
          return null;
        })
        .whereType<PersonaTag>()
        .toList();

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
      autoTagDisabled: json['auto_tag_disabled'] as bool? ?? false,
      personaTags: tags,
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
      'auto_tag_disabled': autoTagDisabled,
      'persona_tags': personaTags.map((t) => t.toJson()).toList(),
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
    bool? autoTagDisabled,
    List<PersonaTag>? personaTags,
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
      autoTagDisabled: autoTagDisabled ?? this.autoTagDisabled,
      personaTags: personaTags ?? this.personaTags,
    );
  }
}

