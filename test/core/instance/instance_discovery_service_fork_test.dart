// Fork: tests the fork adds, kept out of upstream's instance_discovery_service_test.dart so that file stays as
// upstream has it.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/instance/instance_config_snapshot.dart';
import 'package:fluxer_app/core/instance/instance_constants.dart';
import 'package:fluxer_app/core/instance/instance_discovery_service.dart';

import 'instance_discovery_service_test.dart' hide main;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InstanceDiscoveryService', () {
    Map<String, dynamic> buildDiscovery({int apiCodeVersion = 1}) {
      return <String, dynamic>{
        'api_code_version': apiCodeVersion,
        'endpoints': <String, dynamic>{
          'api': 'https://chat.example.com/api',
          'api_client': 'https://chat.example.com/v1',
          'api_public': 'https://chat.example.com/api',
          'gateway': 'wss://gateway.chat.example.com',
          'media': 'https://media.chat.example.com',
          'static_cdn': 'https://static.chat.example.com',
          'marketing': 'https://chat.example.com',
          'admin': 'https://chat.example.com/admin',
          'invite': 'https://chat.example.com',
          'gift': 'https://chat.example.com',
          'webapp': 'https://chat.example.com',
        },
        'captcha': <String, dynamic>{
          'provider': 'none',
          'hcaptcha_site_key': null,
          'turnstile_site_key': null,
        },
        'features': <String, dynamic>{
          'voice_enabled': true,
          'stripe_enabled': false,
          'premium_enabled': false,
          'stripe_serviceable': false,
          'self_hosted': true,
          'presigned_attachment_uploads': true,
          'emails_enabled': true,
        },
        'registration': <String, dynamic>{
          'mode': 'open',
          'admin_registration_urls_enabled': false,
        },
        'community': <String, dynamic>{
          'single_community': false,
          'single_community_guild_id': null,
          'direct_messages_disabled': false,
          'guild_create_access': true,
        },
        'services': <String, dynamic>{
          'gif_enabled': true,
          'youtube_enabled': true,
          'bluesky_enabled': false,
        },
        'gif': <String, dynamic>{
          'provider': 'tenor',
          'display_name': 'Tenor',
          'attribution_required': false,
        },
        'sso': <String, dynamic>{
          'enabled': false,
          'enforced': false,
          'display_name': null,
          'redirect_uri': '',
        },
        'limits': <String, dynamic>{
          'version': 2,
          'traitDefinitions': <String>[],
          'rules': <Map<String, dynamic>>[],
          'defaultsHash': 'hash',
        },
        'push': <String, dynamic>{'public_vapid_key': null},
        'app_public': <String, dynamic>{
          'branding': <String, dynamic>{
            'product_name': 'Fluxer',
            'icon_url': null,
            'symbol_url': null,
            'logo_url': null,
            'wordmark_url': null,
            'favicon_url': null,
            'theme_color': null,
            'premium_product_name': 'Plutonium',
            'premium_info_url': null,
          },
          'setup': <String, dynamic>{'configured': true, 'admin_url': null},
          'legal': <String, dynamic>{'terms_url': null, 'privacy_url': null},
          'registration': <String, dynamic>{'collect_date_of_birth': false},
        },
      };
    }

    Dio buildDio({
      required Map<String, dynamic> responseJson,
      int statusCode = 200,
      String expectedPath = '/api/.well-known/fluxer',
    }) {
      return Dio()
        ..httpClientAdapter = ForkDiscoveryAdapter(
          responseJson: responseJson,
          statusCode: statusCode,
          expectedPath: expectedPath,
        );
    }

    test('connectToEndpoint discovers fluxer.app like any host', () async {
      // Upstream's hosts are not aliases for this build's instance: they go
      // through discovery and use whatever endpoints the server returns.
      final InstanceDiscoveryService service = InstanceDiscoveryService(
        dio: buildDio(responseJson: buildDiscovery()),
      );

      final InstanceConfigSnapshot snapshot = await service.connectToEndpoint(
        'fluxer.app',
      );

      expect(snapshot.apiBaseUrl, 'https://chat.example.com/v1');
      expect(snapshot.apiBaseUrl, isNot(InstanceConstants.defaultApiBaseUrl));
      expect(
        snapshot.displayDomain,
        isNot(InstanceConstants.defaultInstanceInputUrl),
      );
    });
  });
}
