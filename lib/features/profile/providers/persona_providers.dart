// SPDX-License-Identifier: AGPL-3.0-or-later
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/core/talker.dart';
import 'package:fluxer_app/features/chat/data/channel_persona_mention_cache.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/persona_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PersonaMode {
  manual,
  last;

  static PersonaMode fromString(String? value) {
    return switch (value) {
      'last' => PersonaMode.last,
      _ => PersonaMode.manual,
    };
  }

  String toPrefString() => name;
}

class ActivePersonaState {
  const ActivePersonaState({
    this.mode = PersonaMode.manual,
    this.activePersonaId,
    this.isLatched = false,
    this.frecencyUsage = const {},
  });

  final PersonaMode mode;
  final String? activePersonaId;
  final bool isLatched;
  final Map<String, ({int count, int lastUsedAtMs})> frecencyUsage;

  ActivePersonaState copyWith({
    PersonaMode? mode,
    String? Function()? activePersonaId,
    bool? isLatched,
    Map<String, ({int count, int lastUsedAtMs})>? frecencyUsage,
  }) {
    return ActivePersonaState(
      mode: mode ?? this.mode,
      activePersonaId: activePersonaId != null
          ? activePersonaId()
          : this.activePersonaId,
      isLatched: isLatched ?? this.isLatched,
      frecencyUsage: frecencyUsage ?? this.frecencyUsage,
    );
  }
}

// -----------------------------------------------------------------------------
// MyPersonasNotifier & Provider
// -----------------------------------------------------------------------------

class MyPersonasNotifier extends Notifier<AsyncValue<List<Persona>>> {
  @override
  AsyncValue<List<Persona>> build() {
    _loadPersonas();
    return const AsyncValue.loading();
  }

  Future<void> _loadPersonas() async {
    try {
      final Dio dio = ref.read(fluxerDioProvider);
      final Response<dynamic> response =
          await dio.get<dynamic>('/users/@me/personas');
      final dynamic data = response.data;
      final List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['personas'] is List) {
        list = data['personas'] as List<dynamic>;
      } else {
        list = const [];
      }

      final personas = list
          .map((item) {
            if (item is Map<String, dynamic>) {
              return Persona.fromJson(item);
            }
            if (item is Map) {
              return Persona.fromJson(Map<String, dynamic>.from(item));
            }
            return null;
          })
          .whereType<Persona>()
          .where((p) => !p.isDeleted)
          .toList();

      if (!ref.mounted) return;
      state = AsyncValue.data(personas);
    } catch (err, st) {
      talker.warning(
        '[MyPersonasNotifier] Failed to load personas: $err',
        err,
        st,
      );
      if (!ref.mounted) return;
      state = AsyncValue.error(err, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadPersonas();
  }

  Future<void> reloadSilently() async {
    await _loadPersonas();
  }

  void upsertPersona(Persona persona) {
    if (persona.isDeleted) {
      removePersona(persona.id);
      return;
    }
    state.whenData((current) {
      final idx = current.indexWhere((p) => p.id == persona.id);
      if (idx >= 0) {
        final updated = List<Persona>.from(current);
        updated[idx] = persona;
        state = AsyncValue.data(updated);
      } else {
        state = AsyncValue.data([...current, persona]);
      }
    });
  }

  void removePersona(String id) {
    state.whenData((current) {
      state = AsyncValue.data(current.where((p) => p.id != id).toList());
    });
  }

  void reset() {
    state = const AsyncValue.data([]);
  }
}

final myPersonasProvider =
    NotifierProvider<MyPersonasNotifier, AsyncValue<List<Persona>>>(
  MyPersonasNotifier.new,
);

// -----------------------------------------------------------------------------
// ActivePersonaNotifier & Provider
// -----------------------------------------------------------------------------

class ActivePersonaNotifier extends Notifier<ActivePersonaState> {
  static const _kPrefMode = 'persona_active_mode';
  static const _kPrefId = 'persona_active_id';
  static const _kPrefLatched = 'persona_is_latched';
  static const _kPrefFrecency = 'persona_frecency_map';

  @override
  ActivePersonaState build() {
    _initFromPrefs();
    return const ActivePersonaState();
  }

  Future<void> _initFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = prefs.getString(_kPrefMode);
      final idStr = prefs.getString(_kPrefId);
      final latched = prefs.getBool(_kPrefLatched) ?? false;
      final frecencyStr = prefs.getString(_kPrefFrecency);

      final Map<String, ({int count, int lastUsedAtMs})> frecency = {};
      if (frecencyStr != null && frecencyStr.isNotEmpty) {
        try {
          final decoded = jsonDecode(frecencyStr) as Map<String, dynamic>;
          for (final entry in decoded.entries) {
            final val = entry.value as Map<String, dynamic>;
            frecency[entry.key] = (
              count: (val['count'] as num?)?.toInt() ?? 0,
              lastUsedAtMs: (val['last_used'] as num?)?.toInt() ?? 0,
            );
          }
        } catch (_) {}
      }

      state = ActivePersonaState(
        mode: PersonaMode.fromString(modeStr),
        activePersonaId: idStr != null && idStr.isNotEmpty ? idStr : null,
        isLatched: latched,
        frecencyUsage: frecency,
      );
    } catch (e) {
      talker.warning('[ActivePersonaNotifier] Error reading prefs: $e');
    }
  }

  void syncFromSettings({
    required PersonaMode mode,
    required String? activeId,
    required bool isLatched,
  }) {
    state = state.copyWith(
      mode: mode,
      activePersonaId: () => activeId,
      isLatched: isLatched,
    );
  }

  Future<void> setMode(PersonaMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefMode, mode.toPrefString());

    final currentId = state.activePersonaId;
    final latched = currentId != null && currentId.isNotEmpty;
    await prefs.setBool(_kPrefLatched, latched);
    state = state.copyWith(
      mode: mode,
      isLatched: latched,
    );

    try {
      unawaited(
        ref.read(personaSettingsProvider.notifier).updateSettings(
              activePersonaMode: mode.toPrefString(),
            ),
      );
    } catch (_) {}
  }

  Future<void> setActivePersona(
    String? id, {
    bool latch = true,
    PersonaMode? mode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveMode = mode ?? state.mode;

    await prefs.setString(_kPrefMode, effectiveMode.toPrefString());
    if (id != null && id.isNotEmpty) {
      await prefs.setString(_kPrefId, id);
      await prefs.setBool(_kPrefLatched, latch);
    } else {
      await prefs.remove(_kPrefId);
      await prefs.setBool(_kPrefLatched, false);
    }

    state = state.copyWith(
      mode: effectiveMode,
      activePersonaId: () => id != null && id.isNotEmpty ? id : null,
      isLatched: id != null && id.isNotEmpty && latch,
    );

    try {
      unawaited(
        ref.read(personaSettingsProvider.notifier).updateSettings(
              activePersonaId: () => id != null && id.isNotEmpty ? id : null,
              isLatched: id != null && id.isNotEmpty && latch,
              activePersonaMode: effectiveMode.toPrefString(),
            ),
      );
    } catch (_) {}
  }

  Future<void> unlatch({bool preserveMode = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final newMode = state.mode;

    await prefs.setBool(_kPrefLatched, false);
    await prefs.remove(_kPrefId);

    state = state.copyWith(
      mode: newMode,
      activePersonaId: () => null,
      isLatched: false,
    );

    try {
      unawaited(
        ref.read(personaSettingsProvider.notifier).updateSettings(
              isLatched: false,
              activePersonaId: () => null,
              activePersonaMode: newMode.toPrefString(),
            ),
      );
    } catch (_) {}
  }

  Future<void> recordUsage(String personaId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = state.frecencyUsage[personaId];
    final count = (existing?.count ?? 0) + 1;

    final updated = Map<String, ({int count, int lastUsedAtMs})>.from(
      state.frecencyUsage,
    );
    updated[personaId] = (count: count, lastUsedAtMs: now);

    state = state.copyWith(frecencyUsage: updated);

    try {
      final prefs = await SharedPreferences.getInstance();
      final serializable = <String, dynamic>{};
      for (final entry in updated.entries) {
        serializable[entry.key] = {
          'count': entry.value.count,
          'last_used': entry.value.lastUsedAtMs,
        };
      }
      await prefs.setString(_kPrefFrecency, jsonEncode(serializable));
    } catch (_) {}
  }

  Future<void> reset() async {
    state = const ActivePersonaState();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPrefMode);
      await prefs.remove(_kPrefId);
      await prefs.remove(_kPrefLatched);
      await prefs.remove(_kPrefFrecency);
    } catch (_) {}
  }
}

final activePersonaProvider =
    NotifierProvider<ActivePersonaNotifier, ActivePersonaState>(
  ActivePersonaNotifier.new,
);

// -----------------------------------------------------------------------------
// Helper Providers
// -----------------------------------------------------------------------------

final activePersonaOrNullProvider = Provider<Persona?>((ref) {
  final activeState = ref.watch(activePersonaProvider);
  if (!activeState.isLatched || activeState.activePersonaId == null) {
    return null;
  }
  final personasAsync = ref.watch(myPersonasProvider);
  return personasAsync.asData?.value.cast<Persona?>().firstWhere(
        (p) => p?.id == activeState.activePersonaId,
        orElse: () => null,
      );
});

final rankedPersonasProvider = Provider<List<Persona>>((ref) {
  final personas = ref.watch(myPersonasProvider).asData?.value ?? const [];
  if (personas.isEmpty) {
    return const [];
  }

  final activeState = ref.watch(activePersonaProvider);
  final DateTime now = DateTime.now();

  double calculateFrecency(Persona p) {
    final local = activeState.frecencyUsage[p.id];
    final lastUsed = local?.lastUsedAtMs ?? p.lastUsedAtMs;
    final count = (local?.count ?? 0) + p.useCount;
    return calculatePersonaFrecencyScore(
      useCount: count,
      lastUsedAtMs: lastUsed,
      now: now,
    );
  }

  return List<Persona>.from(personas)
    ..sort((a, b) {
      final scoreA = calculateFrecency(a);
      final scoreB = calculateFrecency(b);
      if ((scoreB - scoreA).abs() > 0.001) {
        return scoreB.compareTo(scoreA);
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
});

// -----------------------------------------------------------------------------
// SystemDisplayTagNotifier & Provider
// -----------------------------------------------------------------------------

class SystemDisplayTag {
  const SystemDisplayTag({
    this.text,
    this.iconUrl,
  });

  final String? text;
  final String? iconUrl;

  bool get isEmpty =>
      (text == null || text!.isEmpty) && (iconUrl == null || iconUrl!.isEmpty);
  bool get isNotEmpty => !isEmpty;
}

class SystemDisplayTagNotifier extends Notifier<SystemDisplayTag> {
  static const _kPrefTagText = 'system_display_tag_text';
  static const _kPrefTagIcon = 'system_display_tag_icon';

  @override
  SystemDisplayTag build() {
    unawaited(_initFromPrefs());
    return const SystemDisplayTag();
  }

  Future<void> _initFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedText = prefs.getString(_kPrefTagText);
      final cachedIcon = prefs.getString(_kPrefTagIcon);
      if ((cachedText != null || cachedIcon != null) && state.isEmpty) {
        state = SystemDisplayTag(text: cachedText, iconUrl: cachedIcon);
      }
    } catch (_) {}
  }

  Future<void> _saveToPrefs(String? text, String? icon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (text != null) {
        await prefs.setString(_kPrefTagText, text);
      } else {
        await prefs.remove(_kPrefTagText);
      }
      if (icon != null) {
        await prefs.setString(_kPrefTagIcon, icon);
      } else {
        await prefs.remove(_kPrefTagIcon);
      }
    } catch (_) {}
  }

  void syncFromSettings({
    required String? text,
    required String? iconUrl,
  }) {
    state = SystemDisplayTag(text: text, iconUrl: iconUrl);
    unawaited(_saveToPrefs(text, iconUrl));
  }

  Future<void> updateDisplayTag(String? text, String? iconUrl) async {
    state = SystemDisplayTag(text: text, iconUrl: iconUrl);
    await _saveToPrefs(text, iconUrl);
    await ref.read(personaSettingsProvider.notifier).updateSettings(
          displayTagText: text ?? '',
          displayTagIcon: () => iconUrl,
        );
  }

  Future<void> reset() async {
    state = const SystemDisplayTag();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPrefTagText);
      await prefs.remove(_kPrefTagIcon);
    } catch (_) {}
  }
}

final systemDisplayTagProvider =
    NotifierProvider<SystemDisplayTagNotifier, SystemDisplayTag>(
  SystemDisplayTagNotifier.new,
);

// -----------------------------------------------------------------------------
// PersonaSettingsNotifier & Provider
// -----------------------------------------------------------------------------

class PersonaSettingsNotifier extends Notifier<AsyncValue<PersonaSettings>> {
  @override
  AsyncValue<PersonaSettings> build() {
    _loadSettings();
    return const AsyncValue.loading();
  }

  Future<void> _loadSettings() async {
    try {
      final Dio dio = ref.read(fluxerDioProvider);
      final Response<dynamic> response =
          await dio.get<dynamic>('/users/@me/personas/settings');
      final dynamic data = response.data;
      if (!ref.mounted) return;
      if (data is Map<String, dynamic>) {
        final settings = PersonaSettings.fromJson(data);
        state = AsyncValue.data(settings);
        _syncToLegacyProviders(settings);
      } else if (data is Map) {
        final settings =
            PersonaSettings.fromJson(Map<String, dynamic>.from(data));
        state = AsyncValue.data(settings);
        _syncToLegacyProviders(settings);
      }
    } catch (err, st) {
      talker.warning(
        '[PersonaSettingsNotifier] Failed to load persona settings: $err',
        err,
        st,
      );
      if (!ref.mounted) return;
      state = AsyncValue.error(err, st);
    }
  }

  Future<void> reloadSilently() async {
    await _loadSettings();
  }

  void updateFromGateway(Map<String, dynamic> data) {
    final settings = PersonaSettings.fromJson(data);
    state = AsyncValue.data(settings);
    _syncToLegacyProviders(settings);
  }

  void _syncToLegacyProviders(PersonaSettings settings) {
    ref.read(activePersonaProvider.notifier).syncFromSettings(
          mode: PersonaMode.fromString(settings.activePersonaMode),
          activeId: settings.activePersonaId,
          isLatched: settings.isLatched,
        );
    ref.read(systemDisplayTagProvider.notifier).syncFromSettings(
          text: settings.displayTagText,
          iconUrl: settings.displayTagIcon,
        );
  }

  Future<void> updateSettings({
    String? activePersonaMode,
    String? Function()? activePersonaId,
    bool? isLatched,
    String? displayTagText,
    String? Function()? displayTagIcon,
  }) async {
    final current = state.asData?.value ?? const PersonaSettings();
    final updated = current.copyWith(
      activePersonaMode: activePersonaMode,
      activePersonaId: activePersonaId,
      isLatched: isLatched,
      displayTagText: displayTagText,
      displayTagIcon: displayTagIcon,
    );
    state = AsyncValue.data(updated);
    _syncToLegacyProviders(updated);

    try {
      final Dio dio = ref.read(fluxerDioProvider);
      final body = <String, dynamic>{
        if (activePersonaMode != null) 'active_persona_mode': activePersonaMode,
        if (activePersonaId != null) 'active_persona_id': activePersonaId(),
        if (isLatched != null) 'is_latched': isLatched,
        if (displayTagText != null) 'display_tag_text': displayTagText,
        if (displayTagIcon != null) 'display_tag_icon': displayTagIcon(),
      };
      await dio.patch<dynamic>('/users/@me/personas/settings', data: body);
    } catch (err, st) {
      talker.error(
        '[PersonaSettingsNotifier] Failed to update settings: $err',
        err,
        st,
      );
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadSettings();
  }

  void reset() {
    state = const AsyncValue.data(PersonaSettings());
  }
}

final personaSettingsProvider =
    NotifierProvider<PersonaSettingsNotifier, AsyncValue<PersonaSettings>>(
  PersonaSettingsNotifier.new,
);
