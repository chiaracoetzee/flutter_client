import 'package:fluxer_app/features/profile/domain/persona.dart';

class PublicPersona {
  const PublicPersona({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.bannerUrl,
    this.displayTagText,
    this.displayTagIcon,
    this.pronouns,
    this.color,
    this.avatarColor,
    this.bio,
    this.visibility,
    this.autoTagDisabled = false,
    this.personaTags = const [],
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String? bannerUrl;
  final String? displayTagText;
  final String? displayTagIcon;
  final String? pronouns;
  final int? color;
  final int? avatarColor;
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
          if (t is Map<String, dynamic>) {
            return PersonaTag.fromJson(t);
          }
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
      avatarUrl: json['avatar_url'] as String? ??
          json['avatarUrl'] as String? ??
          json['avatar'] as String?,
      bannerUrl: json['banner_url'] as String? ??
          json['bannerUrl'] as String? ??
          json['banner'] as String?,
      displayTagText: json['display_tag_text'] as String?,
      displayTagIcon: json['display_tag_icon'] as String?,
      pronouns: json['pronouns'] as String?,
      color: (json['color'] as num?)?.toInt(),
      avatarColor: (json['avatar_color'] as num?)?.toInt() ??
          (json['avatarColor'] as num?)?.toInt(),
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
      if (bannerUrl != null) 'banner_url': bannerUrl,
      if (displayTagText != null) 'display_tag_text': displayTagText,
      if (displayTagIcon != null) 'display_tag_icon': displayTagIcon,
      if (pronouns != null) 'pronouns': pronouns,
      if (color != null) 'color': color,
      if (avatarColor != null) 'avatar_color': avatarColor,
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
    String? bannerUrl,
    String? displayTagText,
    String? displayTagIcon,
    String? pronouns,
    int? color,
    int? avatarColor,
    String? bio,
    String? visibility,
    bool? autoTagDisabled,
    List<PersonaTag>? personaTags,
  }) {
    return PublicPersona(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      displayTagText: displayTagText ?? this.displayTagText,
      displayTagIcon: displayTagIcon ?? this.displayTagIcon,
      pronouns: pronouns ?? this.pronouns,
      color: color ?? this.color,
      avatarColor: avatarColor ?? this.avatarColor,
      bio: bio ?? this.bio,
      visibility: visibility ?? this.visibility,
      autoTagDisabled: autoTagDisabled ?? this.autoTagDisabled,
      personaTags: personaTags ?? this.personaTags,
    );
  }

  Persona toPersona({int useCount = 0, int? lastUsedAtMs}) {
    return Persona(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      bannerUrl: bannerUrl,
      pronouns: pronouns,
      color: color,
      avatarColor: avatarColor,
      bio: bio,
      visibility: visibility ?? 'unlisted',
      autoTagDisabled: autoTagDisabled,
      personaTags: personaTags,
      useCount: useCount,
      lastUsedAtMs: lastUsedAtMs,
    );
  }
}
