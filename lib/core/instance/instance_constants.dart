abstract final class InstanceConstants {
  static const int apiCodeVersion = 1;
  static const String defaultApiBaseUrl = 'https://temple.hypersystem.xyz/api';
  static const String defaultGatewayUrl = 'wss://temple.hypersystem.xyz/gateway';
  static const String defaultInstanceInputUrl = 'temple.hypersystem.xyz';
  static const String canaryApiBaseUrl = 'https://canary.fluxer.com/api/v1';
  static const String canaryInstanceInputUrl = 'canary.fluxer.com';
  static const String defaultMarketingBaseUrl = 'https://temple.hypersystem.xyz';
  static const String defaultProductName = 'Fluxer';
  static const int maxRecentInstances = 5;

  static const Set<String> officialInstanceHosts = <String>{
    'temple.hypersystem.xyz',
    'fluxer.app',
    'web.fluxer.app',
    'canary.fluxer.app',
    'web.canary.fluxer.app',
    'fluxer.com',
    'web.fluxer.com',
    'canary.fluxer.com',
    'web.canary.fluxer.com',
  };
}
