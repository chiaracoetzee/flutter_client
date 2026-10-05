abstract final class InstanceConstants {
  static const int apiCodeVersion = 1;
  static const String defaultApiBaseUrl = 'https://temple.hypersystem.xyz/api';
  static const String defaultGatewayUrl = 'wss://temple.hypersystem.xyz/gateway';
  static const String defaultInstanceInputUrl = 'temple.hypersystem.xyz';
  static const String defaultMarketingBaseUrl = 'https://temple.hypersystem.xyz';
  static const String defaultProductName = 'Fluxer';
  static const int maxRecentInstances = 5;

  /// Hosts that mean "this build's own instance" and resolve to the defaults
  /// above without discovery. Upstream's hosts (fluxer.com, fluxer.app, ...)
  /// are deliberately absent: in this fork they are ordinary instances reached
  /// through discovery, never aliases for the default instance.
  static const Set<String> officialInstanceHosts = <String>{
    'temple.hypersystem.xyz',
  };
}
