import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/core/talker.dart';
import 'package:fluxer_app/features/profile/domain/public_persona.dart';

typedef PersonaProfileKey = ({String userId, String personaId});

/// The code the server refuses a persona's profile with when its owner keeps
/// it private, as opposed to the persona not existing.
const String _privatePersonaCode = 'PRIVATE_PERSONA';

/// Profiles the server last refused to this account as private. Written by
/// [publicPersonaProvider] on every fetch and read through
/// [personaProfilePrivateProvider], which waits for that fetch first.
final Set<String> _refusedAsPrivate = <String>{};

String _keyOf(PersonaProfileKey arg) => '${arg.userId}:${arg.personaId}';

bool _isPrivatePersonaRefusal(DioException err) {
  final Object? data = err.response?.data;
  return err.response?.statusCode == 403 &&
      data is Map &&
      data['code'] == _privatePersonaCode;
}

final FutureProviderFamily<PublicPersona?, PersonaProfileKey>
publicPersonaProvider = FutureProvider.family<PublicPersona?, PersonaProfileKey>((
  ref,
  arg,
) async {
  if (arg.userId.isEmpty || arg.personaId.isEmpty) {
    return null;
  }
  final String key = _keyOf(arg);
  try {
    final Dio dio = ref.watch(fluxerDioProvider);
    final Response<dynamic> response = await dio.get<dynamic>(
      '/users/${arg.userId}/personas/${arg.personaId}',
    );
    _refusedAsPrivate.remove(key);
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      return PublicPersona.fromJson(data);
    }
    if (data is Map) {
      return PublicPersona.fromJson(Map<String, dynamic>.from(data));
    }
  } on DioException catch (err, st) {
    if (_isPrivatePersonaRefusal(err)) {
      _refusedAsPrivate.add(key);
      return null;
    }
    _refusedAsPrivate.remove(key);
    talker.warning(
      '[publicPersonaProvider] Failed to fetch persona ${arg.personaId} for user ${arg.userId}: $err',
      err,
      st,
    );
  } on Object catch (err, st) {
    _refusedAsPrivate.remove(key);
    talker.warning(
      '[publicPersonaProvider] Failed to fetch persona ${arg.personaId} for user ${arg.userId}: $err',
      err,
      st,
    );
  }
  return null;
});

/// Whether a persona's profile is withheld because its owner keeps it private,
/// so the card can say so instead of showing nothing. It follows
/// [publicPersonaProvider]: refreshing that refreshes this.
final FutureProviderFamily<bool, PersonaProfileKey>
personaProfilePrivateProvider = FutureProvider.family<bool, PersonaProfileKey>((
  ref,
  arg,
) async {
  await ref.watch(publicPersonaProvider(arg).future);
  return _refusedAsPrivate.contains(_keyOf(arg));
});
