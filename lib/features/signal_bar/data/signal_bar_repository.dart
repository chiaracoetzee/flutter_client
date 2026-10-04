import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/features/signal_bar/domain/signal_bar_models.dart';

/// REST access to the signal bar. The endpoints are not part of the generated
/// SDK, so requests go through the shared authenticated [Dio] directly.
class SignalBarRepository {
  const SignalBarRepository(this._dio);

  final Dio _dio;

  Future<SignalBarConfig> fetchBar() async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>('/instance/signal-bar');
    return SignalBarConfig.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<({int barVersion, List<SignalEntry> entries})> fetchChannel(
    String channelId,
  ) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>('/channels/$channelId/signals');
    final Map<String, dynamic> data =
        response.data ?? const <String, dynamic>{};
    return (
      barVersion: (data['bar_version'] as num?)?.toInt() ?? 0,
      entries: <SignalEntry>[
        for (final Object? item
            in data['entries'] as List<dynamic>? ?? const [])
          SignalEntry.fromJson(item! as Map<String, dynamic>),
      ],
    );
  }

  Future<void> activate(
    String channelId,
    String signalId, {
    String? personaId,
  }) async {
    await _dio.put<void>(
      '/channels/$channelId/signals/$signalId/@me',
      data: <String, dynamic>{'persona_id': ?personaId},
    );
  }

  Future<void> deactivate(String channelId, String signalId) async {
    await _dio.delete<void>('/channels/$channelId/signals/$signalId/@me');
  }

  Future<void> reset(String channelId, String signalId) async {
    await _dio.delete<void>('/channels/$channelId/signals/$signalId');
  }
}

final Provider<SignalBarRepository> signalBarRepositoryProvider =
    Provider<SignalBarRepository>((Ref ref) {
      return SignalBarRepository(ref.watch(fluxerDioProvider));
    });
