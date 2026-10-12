abstract final class InstanceConstants {
  static const int apiCodeVersion = 1;
  static const String defaultApiBaseUrl = 'https://temple.hypersystem.xyz/api';
  static const String defaultGatewayUrl =
      'wss://temple.hypersystem.xyz/gateway';
  static const String defaultInstanceInputUrl = 'temple.hypersystem.xyz';
  static const String defaultMarketingBaseUrl =
      'https://temple.hypersystem.xyz';
  // Fork: the name the app goes by until an instance says what it is called. The fork's builds are
  // given theirs, Tyne, as FORK_APP_NAME in tool/dart_defines/canary.json, the flavour the fork
  // ships. It is not written here because upstream's tests expect the name upstream gives.
  // ignore: do_not_use_environment
  static const String defaultProductName = String.fromEnvironment(
    'FORK_APP_NAME',
    defaultValue: 'Fluxer',
  );
  static const String defaultPremiumProductName = 'Plutonium';
  static const int maxRecentInstances = 5;

  /// Hosts that mean "this build's own instance" and resolve to the defaults
  /// above without discovery. Upstream's hosts (fluxer.com, fluxer.app, ...)
  /// are deliberately absent: in this fork they are ordinary instances reached
  /// through discovery, never aliases for the default instance.
  static const Set<String> officialInstanceHosts = <String>{
    'temple.hypersystem.xyz',
  };
}
