// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/core/synced_preferences/engine/synced_preferences_engine.dart';
import 'package:fluxer_app/core/synced_preferences/engine/synced_preferences_store.dart';
import 'package:fluxer_app/core/synced_preferences/engine/synced_preferences_wire_codec.dart';
import 'package:fluxer_app/core/talker.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/providers/user_settings_status_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PersonaMode {
  off,
  manual,
  last;

  static PersonaMode fromString(String? value) {
    return switch (value) {
      'manual' => PersonaMode.manual,
      'last' => PersonaMode.last,
      _ => PersonaMode.off,
    };
  }

  String toPrefString() => name;
}

class ActivePersonaState {
  const ActivePersonaState({
    this.mode = PersonaMode.off,
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
          .whereType<Map<String, dynamic>>()
          .map(Persona.fromJson)
          .toList();

      state = AsyncValue.data(personas);
    } catch (err, st) {
      talker.warning(
        '[MyPersonasNotifier] Failed to load personas: $err',
        err,
        st,
      );
      state = AsyncValue.error(err, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadPersonas();
  }

  void upsertPersona(Persona persona) {
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

  Future<void> setMode(PersonaMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefMode, mode.toPrefString());

    if (mode == PersonaMode.off) {
      await prefs.remove(_kPrefId);
      await prefs.setBool(_kPrefLatched, false);
      state = state.copyWith(
        mode: mode,
        activePersonaId: () => null,
        isLatched: false,
      );
    } else if (mode == PersonaMode.manual) {
      final currentId = state.activePersonaId;
      final targetId = currentId ?? '';
      await prefs.setString(_kPrefId, targetId);
      await prefs.setBool(_kPrefLatched, targetId.isNotEmpty);
      state = state.copyWith(
        mode: mode,
        isLatched: targetId.isNotEmpty,
      );
    } else if (mode == PersonaMode.last) {
      final currentId = state.activePersonaId;
      final latched = currentId != null && currentId.isNotEmpty;
      await prefs.setBool(_kPrefLatched, latched);
      state = state.copyWith(
        mode: mode,
        isLatched: latched,
      );
    }
  }

  Future<void> setActivePersona(
    String? id, {
    bool latch = true,
    PersonaMode? mode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveMode = mode ??
        (id != null && latch && state.mode == PersonaMode.off
            ? PersonaMode.manual
            : state.mode);

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
  }

  Future<void> unlatch({bool preserveMode = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final shouldPreserve = preserveMode || state.mode == PersonaMode.last;
    final newMode = shouldPreserve ? state.mode : PersonaMode.off;

    await prefs.setBool(_kPrefLatched, false);
    await prefs.remove(_kPrefId);
    if (!shouldPreserve) {
      await prefs.setString(_kPrefMode, newMode.toPrefString());
    }

    state = state.copyWith(
      mode: newMode,
      activePersonaId: () => null,
      isLatched: false,
    );
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
  if (personas.isEmpty) return const [];

  final activeState = ref.watch(activePersonaProvider);
  final nowMs = DateTime.now().millisecondsSinceEpoch;

  double calculateFrecency(Persona p) {
    final local = activeState.frecencyUsage[p.id];
    final lastUsed = local?.lastUsedAtMs ?? p.lastUsedAtMs ?? 0;
    final count = (local?.count ?? 0) + p.useCount;
    if (lastUsed == 0) return 0;
    final hoursAgo = math.max(0.0, (nowMs - lastUsed) / (1000.0 * 60 * 60));
    final recencyFactor = math.pow(0.5, hoursAgo / 24.0);
    return ((count + 1) * recencyFactor).toDouble();
  }

  final sorted = List<Persona>.from(personas);
  sorted.sort((a, b) {
    final scoreA = calculateFrecency(a);
    final scoreB = calculateFrecency(b);
    return scoreB.compareTo(scoreA);
  });
  return sorted;
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
    _initFromPrefs();

    // Check user settings immediately if available
    final initialSettings = ref.watch(userSettingsStatusProvider);
    if (initialSettings != null && initialSettings.syncedPreferences.isNotEmpty) {
      final parsed = _parseBlob(initialSettings.syncedPreferences);
      if (parsed.text != null || parsed.iconUrl != null) {
        _saveToPrefs(parsed.text, parsed.iconUrl);
        return parsed;
      }
    }

    // Also check syncedPreferencesStore if available
    final store = ref.watch(syncedPreferencesStoreProvider);
    if (store.displayTagText != null || store.displayTagIcon != null) {
      final fromStore = SystemDisplayTag(
        text: store.displayTagText,
        iconUrl: store.displayTagIcon,
      );
      _saveToPrefs(fromStore.text, fromStore.iconUrl);
      return fromStore;
    }

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

  static SystemDisplayTag _parseBlob(String wireBlob) {
    if (wireBlob.isEmpty) return const SystemDisplayTag();
    try {
      final bytes = SyncedPreferencesEngine.decodeBytes(wireBlob);
      String? text;
      final textChunks =
          SyncedPreferencesWireCodec.extractFieldChunks(bytes, 124);
      if (textChunks.isNotEmpty) {
        text = SyncedPreferencesWireCodec.decodeStringFromChunk(textChunks.last);
      }
      String? icon;
      final iconChunks =
          SyncedPreferencesWireCodec.extractFieldChunks(bytes, 125);
      if (iconChunks.isNotEmpty) {
        icon = SyncedPreferencesWireCodec.decodeStringFromChunk(iconChunks.last);
      }
      return SystemDisplayTag(text: text, iconUrl: icon);
    } catch (_) {
      return const SystemDisplayTag();
    }
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

  void updateFromBlob(String wireBlob) {
    final parsed = _parseBlob(wireBlob);
    if (parsed.text != state.text || parsed.iconUrl != state.iconUrl) {
      state = parsed;
      _saveToPrefs(parsed.text, parsed.iconUrl);
    }
  }
}

final systemDisplayTagProvider =
    NotifierProvider<SystemDisplayTagNotifier, SystemDisplayTag>(
  SystemDisplayTagNotifier.new,
);

