// Fork: tests for lib/shared/utils/fork_image_upload_limit.dart.
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/limits/instance_limit_provider.dart';
import 'package:fluxer_app/core/limits/limit_key.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/fork_image_upload_limit.dart';

const int _kTwentyMegabytes = 20 * 1024 * 1024;

Future<WidgetRef> _pumpRef(
  WidgetTester tester, {
  required int avatarMaxSize,
}) async {
  late WidgetRef captured;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        instanceLimitProvider(
          LimitKeys.avatarMaxSize,
        ).overrideWith((Ref ref) => avatarMaxSize),
      ],
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          captured = ref;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return captured;
}

void main() {
  testWidgets('uses the instance avatar_max_size, not a fixed 10 MB', (
    WidgetTester tester,
  ) async {
    final WidgetRef ref = await _pumpRef(
      tester,
      avatarMaxSize: _kTwentyMegabytes,
    );

    expect(isImageOverUploadLimit(ref, Uint8List(15 * 1024 * 1024)), isFalse);
    expect(isImageOverUploadLimit(ref, Uint8List(_kTwentyMegabytes)), isFalse);
    expect(
      isImageOverUploadLimit(ref, Uint8List(_kTwentyMegabytes + 1)),
      isTrue,
    );
  });

  testWidgets('the error message names the instance limit', (
    WidgetTester tester,
  ) async {
    final WidgetRef ref = await _pumpRef(
      tester,
      avatarMaxSize: _kTwentyMegabytes,
    );
    final FluxerLocalizations l10n = await FluxerLocalizations.delegate.load(
      const Locale('en'),
    );

    expect(
      imageFileTooLargeMessage(l10n, ref),
      'Image file is too large. Please choose a file smaller than 20 MB.',
    );
  });
}
