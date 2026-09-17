// SPDX-License-Identifier: AGPL-3.0-or-later

class PersonaSettings {
  const PersonaSettings({
    this.userId = '',
    this.activePersonaMode = 'off',
    this.activePersonaId,
    this.isLatched = false,
    this.displayTagText = '',
    this.displayTagIcon,
  });

  final String userId;
  final String activePersonaMode;
  final String? activePersonaId;
  final bool isLatched;
  final String displayTagText;
  final String? displayTagIcon;

  factory PersonaSettings.fromJson(Map<String, dynamic> json) {
    return PersonaSettings(
      userId: (json['user_id'] as String?) ?? '',
      activePersonaMode: (json['active_persona_mode'] as String?) ?? 'off',
      activePersonaId: json['active_persona_id'] as String?,
      isLatched: (json['is_latched'] as bool?) ?? false,
      displayTagText: (json['display_tag_text'] as String?) ?? '',
      displayTagIcon: json['display_tag_icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'user_id': userId,
      'active_persona_mode': activePersonaMode,
      if (activePersonaId != null) 'active_persona_id': activePersonaId,
      'is_latched': isLatched,
      'display_tag_text': displayTagText,
      if (displayTagIcon != null) 'display_tag_icon': displayTagIcon,
    };
  }

  PersonaSettings copyWith({
    String? userId,
    String? activePersonaMode,
    String? Function()? activePersonaId,
    bool? isLatched,
    String? displayTagText,
    String? Function()? displayTagIcon,
  }) {
    return PersonaSettings(
      userId: userId ?? this.userId,
      activePersonaMode: activePersonaMode ?? this.activePersonaMode,
      activePersonaId:
          activePersonaId != null ? activePersonaId() : this.activePersonaId,
      isLatched: isLatched ?? this.isLatched,
      displayTagText: displayTagText ?? this.displayTagText,
      displayTagIcon:
          displayTagIcon != null ? displayTagIcon() : this.displayTagIcon,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonaSettings &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          activePersonaMode == other.activePersonaMode &&
          activePersonaId == other.activePersonaId &&
          isLatched == other.isLatched &&
          displayTagText == other.displayTagText &&
          displayTagIcon == other.displayTagIcon;

  @override
  int get hashCode => Object.hash(
        userId,
        activePersonaMode,
        activePersonaId,
        isLatched,
        displayTagText,
        displayTagIcon,
      );
}
