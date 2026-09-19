import 'dart:convert';

import 'package:fluxer_app/core/instance/instance_constants.dart';
import 'package:fluxer_app/core/instance/instance_endpoint_normalizer.dart';
import 'package:fluxer_dart/export.dart';

class InstanceConfigSnapshot {
  const InstanceConfigSnapshot({
    required this.apiBaseUrl,
    required this.gatewayUrl,
    required this.displayDomain,
    this.wellKnown,
  });

  final String apiBaseUrl;
  final String gatewayUrl;
  final String displayDomain;
  final WellKnownFluxerResponse? wellKnown;

  factory InstanceConfigSnapshot.fromWellKnown({
    required WellKnownFluxerResponse wellKnown,
    required InstanceEndpointNormalizer normalizer,
  }) {
    final String apiBaseUrl = normalizer.resolveApiBaseUrl(wellKnown);
    final String gatewayUrl = normalizer.resolveGatewayUrl(wellKnown);
    final String displayDomain = normalizer.displayDomainForSnapshot(
      apiBaseUrl: apiBaseUrl,
      gatewayUrl: gatewayUrl,
    );

    return InstanceConfigSnapshot(
      apiBaseUrl: apiBaseUrl,
      gatewayUrl: gatewayUrl,
      displayDomain: displayDomain,
      wellKnown: wellKnown,
    );
  }

  factory InstanceConfigSnapshot.officialDefault() {
    return const InstanceConfigSnapshot(
      apiBaseUrl: InstanceConstants.defaultApiBaseUrl,
      gatewayUrl: InstanceConstants.defaultGatewayUrl,
      displayDomain: InstanceConstants.defaultInstanceInputUrl,
    );
  }

  factory InstanceConfigSnapshot.fromJson(String json) {
    final Map<String, dynamic> map = jsonDecode(json) as Map<String, dynamic>;
    return InstanceConfigSnapshot(
      apiBaseUrl: map['api_base_url'] as String,
      gatewayUrl: map['gateway_url'] as String? ?? '',
      displayDomain: map['display_domain'] as String,
      wellKnown: _wellKnownFromJson(map['well_known']),
    );
  }

  static WellKnownFluxerResponse? _wellKnownFromJson(dynamic value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }
    try {
      return WellKnownFluxerResponse.fromJson(value);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'api_base_url': apiBaseUrl,
      'gateway_url': gatewayUrl,
      'display_domain': displayDomain,
      'well_known': wellKnown?.toJson(),
    };
  }

  String toJson() => jsonEncode(toMap());

  InstanceConfigSnapshot copyWith({
    String? apiBaseUrl,
    String? gatewayUrl,
    String? displayDomain,
    WellKnownFluxerResponse? wellKnown,
  }) {
    return InstanceConfigSnapshot(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      gatewayUrl: gatewayUrl ?? this.gatewayUrl,
      displayDomain: displayDomain ?? this.displayDomain,
      wellKnown: wellKnown ?? this.wellKnown,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is InstanceConfigSnapshot &&
        other.apiBaseUrl == apiBaseUrl &&
        other.gatewayUrl == gatewayUrl &&
        other.displayDomain == displayDomain &&
        _wellKnownEquals(other.wellKnown, wellKnown);
  }

  @override
  int get hashCode => Object.hash(
    apiBaseUrl,
    gatewayUrl,
    displayDomain,
    wellKnown?.toJson().toString(),
  );

  static bool _wellKnownEquals(
    WellKnownFluxerResponse? a,
    WellKnownFluxerResponse? b,
  ) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null) {
      return false;
    }
    return a.toJson().toString() == b.toJson().toString();
  }
}
