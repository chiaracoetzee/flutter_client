// SPDX-License-Identifier: AGPL-3.0-or-later

class SignatureEmoji {
  const SignatureEmoji({
    this.id,
    required this.name,
    this.animated,
  });

  /// Custom emoji ID (null for Unicode emojis).
  final String? id;

  /// Emoji name or Unicode character.
  final String name;

  /// Whether the emoji is animated.
  final bool? animated;

  bool get isCustom => id != null && id!.isNotEmpty;

  factory SignatureEmoji.fromJson(Map<String, dynamic> json) {
    return SignatureEmoji(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      animated: json['animated'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      if (animated != null) 'animated': animated,
    };
  }

  bool matches({
    String? emojiId,
    required String emojiName,
    String? surrogates,
  }) {
    if (id != null && id!.isNotEmpty && emojiId != null && emojiId.isNotEmpty) {
      return id == emojiId;
    }
    if ((id == null || id!.isEmpty) && (emojiId == null || emojiId.isEmpty)) {
      if (name == emojiName) return true;
      if (surrogates != null && name == surrogates) return true;
      if (emojiName == surrogates) return true;
    }
    return false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignatureEmoji &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => (id ?? '').hashCode ^ name.hashCode;
}
