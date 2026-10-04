import 'package:dio/dio.dart';
import 'package:fluxer_app/features/auth/domain/phone_verification_models.dart';
import 'package:fluxer_app/features/auth/utils/phone_verification_errors.dart';

class PhoneVerificationRepository {
  const PhoneVerificationRepository(this._dio);

  final Dio _dio;

  Future<PhoneSendVerificationResponse> sendVerification({
    required String phone,
    PhoneSendVerificationRequestChannel? channel,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/users/@me/phone/send-verification',
      data: PhoneSendVerificationRequest(phone: phone, channel: channel).toJson(),
    );
    return PhoneSendVerificationResponse.fromJson(
      response.data ?? <String, dynamic>{},
    );
  }

  Future<void> verifyCode({required String phone, required String code}) async {
    await _dio.post<Map<String, dynamic>>(
      '/users/@me/phone/verify',
      data: PhoneVerifyRequest(
        phone: phone,
        code: normalizeVerificationCode(code),
      ).toJson(),
    );
  }

  Future<InboundSmsChallengeStartResponse> startInboundChallenge() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/users/@me/phone/inbound-challenge',
    );
    return InboundSmsChallengeStartResponse.fromJson(
      response.data ?? <String, dynamic>{},
    );
  }
}
