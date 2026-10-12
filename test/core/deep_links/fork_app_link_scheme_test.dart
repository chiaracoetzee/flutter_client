// Fork: Tyne opens tyne:// links handed to it by the system, and still reads the fluxer: links
// written inside messages.

import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/deep_links/deep_link_path_policy.dart';

void main() {
  group('links in the scheme of this app', () {
    test('a tyne:// link becomes the same path as the fluxer:// one', () {
      for (final String rest in <String>[
        'channels/@me/123',
        'invite/abc',
        'settings/user?section=appearance',
        'users/42',
      ]) {
        final Uri tyne = normalizeAppProtocolDeepLinkUri(
          Uri.parse('$forkAppLinkScheme://$rest'),
        );
        final Uri fluxer = normalizeAppProtocolDeepLinkUri(
          Uri.parse('$appProtocolScheme://$rest'),
        );
        expect(tyne, fluxer, reason: rest);
        expect(tyne.scheme, isEmpty, reason: rest);
        expect(tyne.path, startsWith('/'), reason: rest);
      }
    });

    test(
      'an invite in the scheme of this app resolves to the invite route',
      () {
        expect(
          normalizeInviteDeepLinkUri(Uri.parse('tyne://invite/abc')).path,
          '/invite/abc',
        );
      },
    );

    test('a link in another scheme is left as it is', () {
      for (final String link in <String>[
        'https://example.com/channels/@me',
        'tynex://channels/@me',
        'mailto:someone@example.com',
      ]) {
        final Uri uri = Uri.parse(link);
        expect(normalizeAppProtocolDeepLinkUri(uri), uri, reason: link);
      }
    });
  });
}
