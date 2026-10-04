enum PhoneSendVerificationRequestChannel {
  sms('sms'),
  inboundChallenge('inbound_challenge');

  const PhoneSendVerificationRequestChannel(this.json);
  final String json;
}

class PhoneSendVerificationRequest {
  const PhoneSendVerificationRequest({
    required this.phone,
    this.channel,
  });

  final String phone;
  final PhoneSendVerificationRequestChannel? channel;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'phone': phone,
        if (channel != null) 'channel': channel!.json,
      };
}

class PhoneSendVerificationResponseVariant2 {
  const PhoneSendVerificationResponseVariant2({
    required this.channel,
    required this.challengeCode,
    required this.ourNumber,
    required this.expiresAt,
    this.reason,
  });

  factory PhoneSendVerificationResponseVariant2.fromJson(
    Map<String, dynamic> json,
  ) {
    return PhoneSendVerificationResponseVariant2(
      channel: json['channel'] as String? ?? 'inbound_challenge',
      challengeCode: json['challenge_code'] as String? ?? '',
      ourNumber: json['our_number'] as String? ?? '',
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? '') ??
          DateTime.now(),
      reason: json['reason'] as String?,
    );
  }

  final String channel;
  final String challengeCode;
  final String ourNumber;
  final DateTime expiresAt;
  final String? reason;
}

class PhoneSendVerificationResponse {
  const PhoneSendVerificationResponse(this._json);

  factory PhoneSendVerificationResponse.fromJson(Map<String, dynamic> json) =>
      PhoneSendVerificationResponse(json);

  final Map<String, dynamic> _json;

  Map<String, dynamic> toJson() => _json;

  PhoneSendVerificationResponseVariant2 toVariant2() =>
      PhoneSendVerificationResponseVariant2.fromJson(_json);
}

class PhoneVerifyRequest {
  const PhoneVerifyRequest({required this.phone, required this.code});

  final String phone;
  final String code;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'phone': phone,
        'code': code,
      };
}

class InboundSmsChallengeStartResponse {
  const InboundSmsChallengeStartResponse({
    required this.challengeCode,
    required this.ourNumber,
    required this.expiresAt,
  });

  factory InboundSmsChallengeStartResponse.fromJson(
    Map<String, Object?> json,
  ) {
    return InboundSmsChallengeStartResponse(
      challengeCode: json['challenge_code'] as String? ?? '',
      ourNumber: json['our_number'] as String? ?? '',
      expiresAt: json['expires_at'] as String? ?? '',
    );
  }

  final String challengeCode;
  final String ourNumber;
  final String expiresAt;

  Map<String, Object?> toJson() => <String, Object?>{
        'challenge_code': challengeCode,
        'our_number': ourNumber,
        'expires_at': expiresAt,
      };
}
