import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/core/talker.dart';
import 'package:fluxer_app/features/profile/domain/public_persona.dart';

final publicPersonaProvider = FutureProvider.family<
    PublicPersona?,
    ({String userId, String personaId})>((ref, arg) async {
  if (arg.userId.isEmpty || arg.personaId.isEmpty) {
    return null;
  }
  try {
    final Dio dio = ref.watch(fluxerDioProvider);
    final Response<dynamic> response = await dio.get<dynamic>(
      '/users/${arg.userId}/personas/${arg.personaId}',
    );
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      return PublicPersona.fromJson(data);
    }
    if (data is Map) {
      return PublicPersona.fromJson(Map<String, dynamic>.from(data));
    }
  } catch (err, st) {
    talker.warning(
      '[publicPersonaProvider] Failed to fetch persona ${arg.personaId} for user ${arg.userId}: $err',
      err,
      st,
    );
  }
  return null;
});
