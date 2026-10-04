import 'package:flutter/foundation.dart';

/// One toggleable signal on the instance-wide signal bar.
@immutable
class SignalBarSignal {
  const SignalBarSignal({
    required this.id,
    required this.emojiName,
    required this.animated,
    this.emojiId,
    this.label,
  });

  factory SignalBarSignal.fromJson(Map<String, dynamic> json) {
    return SignalBarSignal(
      id: json['id'] as String,
      emojiId: json['emoji_id'] as String?,
      emojiName: json['emoji_name'] as String,
      animated: json['animated'] as bool? ?? false,
      label: json['label'] as String?,
    );
  }

  final String id;
  final String? emojiId;
  final String emojiName;
  final bool animated;
  final String? label;

  String get displayLabel =>
      (label != null && label!.isNotEmpty) ? label! : emojiName;
}

/// The bar as configured by the home community's managers.
@immutable
class SignalBarConfig {
  const SignalBarConfig({
    required this.version,
    required this.signals,
    this.guildId,
    this.canManage = false,
  });

  factory SignalBarConfig.fromJson(Map<String, dynamic> json) {
    return SignalBarConfig(
      version: (json['version'] as num?)?.toInt() ?? 0,
      signals: <SignalBarSignal>[
        for (final Object? item
            in json['signals'] as List<dynamic>? ?? const [])
          SignalBarSignal.fromJson(item! as Map<String, dynamic>),
      ],
      guildId: json['guild_id'] as String?,
      canManage: json['can_manage'] as bool? ?? false,
    );
  }

  static const SignalBarConfig empty = SignalBarConfig(
    version: -1,
    signals: <SignalBarSignal>[],
  );

  final int version;
  final List<SignalBarSignal> signals;
  final String? guildId;
  final bool canManage;
}

/// One account currently giving a signal in a channel. An account holds at
/// most one entry per signal; [personaId] is whoever it is signalling as now.
@immutable
class SignalEntry {
  const SignalEntry({
    required this.signalId,
    required this.userId,
    required this.username,
    this.globalName,
    this.userAvatar,
    this.personaId,
    this.personaName,
    this.personaAvatar,
  });

  factory SignalEntry.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user = json['user'] as Map<String, dynamic>;
    final Map<String, dynamic>? subprofile =
        json['subprofile'] as Map<String, dynamic>?;
    return SignalEntry(
      signalId: json['signal_id'] as String,
      userId: user['id'] as String,
      username: user['username'] as String? ?? '',
      globalName: user['global_name'] as String?,
      userAvatar: user['avatar'] as String?,
      personaId: json['persona_id'] as String?,
      personaName: subprofile?['name'] as String?,
      personaAvatar: subprofile?['avatar'] as String?,
    );
  }

  final String signalId;
  final String userId;
  final String username;
  final String? globalName;
  final String? userAvatar;
  final String? personaId;
  final String? personaName;
  final String? personaAvatar;

  String get displayName {
    if (personaName != null && personaName!.isNotEmpty) {
      return personaName!;
    }
    if (globalName != null && globalName!.isNotEmpty) {
      return globalName!;
    }
    return username;
  }

  SignalEntry withPersona({
    required String? personaId,
    required String? personaName,
    required String? personaAvatar,
  }) {
    return SignalEntry(
      signalId: signalId,
      userId: userId,
      username: username,
      globalName: globalName,
      userAvatar: userAvatar,
      personaId: personaId,
      personaName: personaName,
      personaAvatar: personaAvatar,
    );
  }
}

/// The persona an account is acting as right now, as resolved by the composer.
@immutable
class SignalPersona {
  const SignalPersona({required this.id, required this.name, this.avatar});

  final String id;
  final String name;
  final String? avatar;
}

/// Applies a CHANNEL_SIGNAL_UPDATE payload to a channel's entries. Removed
/// entries are dropped; added entries replace the same account's entry on the
/// same signal in place, or are appended.
List<SignalEntry> applySignalUpdate(
  List<SignalEntry> current, {
  required List<SignalEntry> added,
  required List<({String signalId, String userId})> removed,
}) {
  final List<SignalEntry> next = <SignalEntry>[
    for (final SignalEntry entry in current)
      if (!removed.any(
        (r) => r.signalId == entry.signalId && r.userId == entry.userId,
      ))
        entry,
  ];
  for (final SignalEntry entry in added) {
    final int index = next.indexWhere(
      (e) => e.signalId == entry.signalId && e.userId == entry.userId,
    );
    if (index == -1) {
      next.add(entry);
    } else {
      next[index] = entry;
    }
  }
  return next;
}
