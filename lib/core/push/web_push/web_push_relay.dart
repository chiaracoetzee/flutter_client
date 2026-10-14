const String kPushRelayOrigin = 'https://push.fluxer.com';

String fcmRelayUrl({required String appId, required String deviceToken}) {
  return '$kPushRelayOrigin/relay/v1/fcm/${_segment(appId)}/${_segment(deviceToken)}';
}

String apnsRelayUrl({
  required String appId,
  required String environment,
  required String deviceTokenHex,
}) {
  return '$_apnsRelayOrigin/relay/v1/apns/'
      '${_segment(appId)}/${_segment(environment)}/${_segment(deviceTokenHex)}';
}

String apnsVoipRelayUrl({
  required String appId,
  required String environment,
  required String deviceTokenHex,
}) {
  return '$_apnsRelayOrigin/relay/v1/apns-voip/'
      '${_segment(appId)}/${_segment(environment)}/${_segment(deviceTokenHex)}';
}

bool isFluxerPushRelayUrl(String token) {
  final Uri? parsed = Uri.tryParse(token);
  if (parsed == null) {
    return false;
  }
  final Uri origin = Uri.parse(kPushRelayOrigin);
  if (parsed.scheme != origin.scheme || parsed.host != origin.host) {
    return false;
  }
  if (parsed.hasPort && parsed.port != origin.port) {
    return false;
  }
  final List<String> segments = parsed.pathSegments;
  if (segments.length < 3) {
    return false;
  }
  if (segments[0] != 'relay' || segments[1] != 'v1') {
    return false;
  }
  return segments[2] == 'fcm' ||
      segments[2] == 'apns' ||
      segments[2] == 'apns-voip';
}

String _segment(String value) => Uri.encodeComponent(value);

const String kPushRelayProviderApple = 'Apple';
const String kPushRelayProviderGoogle = 'Google';

String pushRelayProviderName({required bool isApple}) =>
    isApple ? kPushRelayProviderApple : kPushRelayProviderGoogle;

// Fork: the fork's iOS app has its own APNs key, which Fluxer's relay does not have. Its relay
// URLs therefore name a host of the fork's, FORK_APNS_RELAY_ORIGIN in
// tool/dart_defines/canary.json, which the instance's push service delivers itself
// (FLUXER_PUSH_SERVICE_OWN_RELAY_HOSTS). They are not Fluxer relay URLs, so no relay consent is
// asked for them. Without the setting, upstream's relay is used.
// ignore: do_not_use_environment -- compile-time build flavor config
const String _forkApnsRelayOrigin = String.fromEnvironment(
  'FORK_APNS_RELAY_ORIGIN',
);

String get _apnsRelayOrigin =>
    _forkApnsRelayOrigin.isEmpty ? kPushRelayOrigin : _forkApnsRelayOrigin;
