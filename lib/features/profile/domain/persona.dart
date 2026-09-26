// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fluxer_app/features/profile/domain/public_persona.dart';

class PersonaTag {
  const PersonaTag({
    this.prefix,
    this.suffix,
  });

  final String? prefix;
  final String? suffix;

  factory PersonaTag.fromJson(Map<String, dynamic> json) {
    return PersonaTag(
      prefix: json['prefix'] as String?,
      suffix: json['suffix'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (prefix != null) 'prefix': prefix,
      if (suffix != null) 'suffix': suffix,
    };
  }

  String get displayPattern {
    final p = prefix ?? '';
    final s = suffix ?? '';
    if (p.isEmpty && s.isEmpty) {
      return '';
    }
    return '${p}text$s';
  }
}

class Persona {
  const Persona({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.bannerUrl,
    this.pronouns,
    this.color,
    this.avatarColor,
    this.bio,
    this.autoTagDisabled = false,
    this.personaTags = const [],
    this.useCount = 0,
    this.lastUsedAtMs,
    this.visibility = 'unlisted',
    this.externalUuid,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String? bannerUrl;
  final String? pronouns;
  final int? color;
  final int? avatarColor;
  final String? bio;
  final bool autoTagDisabled;
  final List<PersonaTag> personaTags;
  final int useCount;
  final int? lastUsedAtMs;
  final String visibility;
  final String? externalUuid;
  final String? createdAt;
  final String? updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  factory Persona.fromJson(Map<String, dynamic> json) {
    final rawTags = json['persona_tags'] as List<dynamic>? ??
        json['personaTags'] as List<dynamic>? ??
        const [];
    final tags = rawTags
        .whereType<Map<dynamic, dynamic>>()
        .map((t) => PersonaTag.fromJson(Map<String, dynamic>.from(t)))
        .toList();

    int? lastUsed;
    final rawLastUsed = json['last_used_at_ms'] ?? json['lastUsedAtMs'];
    if (rawLastUsed is num) {
      lastUsed = rawLastUsed.toInt();
    } else if (rawLastUsed is String) {
      lastUsed = int.tryParse(rawLastUsed);
    }

    return Persona(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      avatarUrl: (json['avatar_url'] as String?) ??
          (json['avatarUrl'] as String?) ??
          (json['avatar'] as String?),
      bannerUrl: (json['banner_url'] as String?) ??
          (json['bannerUrl'] as String?) ??
          (json['banner'] as String?),
      pronouns: json['pronouns'] as String?,
      color: (json['color'] as num?)?.toInt() ??
          (json['accentColor'] as num?)?.toInt() ??
          (json['accent_color'] as num?)?.toInt(),
      avatarColor: (json['avatar_color'] as num?)?.toInt() ??
          (json['avatarColor'] as num?)?.toInt(),
      bio: json['bio'] as String?,
      autoTagDisabled: (json['auto_tag_disabled'] as bool?) ??
          (json['autoTagDisabled'] as bool?) ??
          false,
      personaTags: tags,
      useCount: (json['use_count'] as num?)?.toInt() ??
          (json['useCount'] as num?)?.toInt() ??
          0,
      lastUsedAtMs: lastUsed,
      visibility: (json['visibility'] as String?) ?? 'unlisted',
      externalUuid: (json['external_uuid'] as String?) ??
          (json['externalUuid'] as String?),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: (json['deleted_at'] != null || json['deletedAt'] != null)
          ? DateTime.tryParse(
              (json['deleted_at'] ?? json['deletedAt']) as String,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (bannerUrl != null) 'banner_url': bannerUrl,
      if (pronouns != null) 'pronouns': pronouns,
      if (color != null) 'color': color,
      if (avatarColor != null) 'avatar_color': avatarColor,
      if (bio != null) 'bio': bio,
      'auto_tag_disabled': autoTagDisabled,
      'persona_tags': personaTags.map((t) => t.toJson()).toList(),
      'use_count': useCount,
      if (lastUsedAtMs != null) 'last_used_at_ms': lastUsedAtMs.toString(),
      'visibility': visibility,
      if (externalUuid != null) 'external_uuid': externalUuid,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
    };
  }

  Persona copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? bannerUrl,
    String? pronouns,
    int? color,
    int? avatarColor,
    String? bio,
    bool? autoTagDisabled,
    List<PersonaTag>? personaTags,
    int? useCount,
    int? lastUsedAtMs,
    String? visibility,
    String? externalUuid,
    String? createdAt,
    String? updatedAt,
    DateTime? deletedAt,
  }) {
    return Persona(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      pronouns: pronouns ?? this.pronouns,
      color: color ?? this.color,
      avatarColor: avatarColor ?? this.avatarColor,
      bio: bio ?? this.bio,
      autoTagDisabled: autoTagDisabled ?? this.autoTagDisabled,
      personaTags: personaTags ?? this.personaTags,
      useCount: useCount ?? this.useCount,
      lastUsedAtMs: lastUsedAtMs ?? this.lastUsedAtMs,
      visibility: visibility ?? this.visibility,
      externalUuid: externalUuid ?? this.externalUuid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  PublicPersona toPublicPersona() {
    return PublicPersona(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      bannerUrl: bannerUrl,
      pronouns: pronouns,
      color: color,
      avatarColor: avatarColor,
      bio: bio,
      visibility: visibility,
      autoTagDisabled: autoTagDisabled,
      personaTags: personaTags,
    );
  }

  Map<String, dynamic> toSubprofilePayload({
    String? displayTagText,
    String? displayTagIcon,
  }) {
    final String? trimmedTagText =
        (displayTagText != null && displayTagText.trim().isNotEmpty)
            ? displayTagText.trim()
            : null;
    final String? trimmedTagIcon =
        (displayTagIcon != null && displayTagIcon.trim().isNotEmpty)
            ? displayTagIcon.trim()
            : null;
    final int? effectiveColor = avatarColor ?? color;
    return <String, dynamic>{
      'id': id,
      'name': name,
      if (avatarUrl != null) 'avatar': avatarUrl,
      if (bannerUrl != null) 'banner': bannerUrl,
      if (effectiveColor != null) 'avatar_color': effectiveColor,
      if (trimmedTagText != null) 'display_tag_text': trimmedTagText,
      if (trimmedTagText != null) 'system_name': trimmedTagText,
      if (trimmedTagIcon != null) 'display_tag_icon': trimmedTagIcon,
      if (pronouns != null) 'pronouns': pronouns,
      if (effectiveColor != null) 'color': effectiveColor,
      if (bio != null) 'bio': bio,
    };
  }
}
