// Fork: tests the fork adds, kept out of upstream's attachment_native_pickers_test.dart so that
// file stays as upstream has it.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/domain/pending_attachment.dart';
import 'package:fluxer_app/features/chat/utils/attachments/attachment_native_pickers.dart';

import 'attachment_native_pickers_test.dart' hide main;

const MethodChannel _attachmentMediaChannel = MethodChannel(
  'fluxer_app/attachment_media',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_attachmentMediaChannel, (
          MethodCall call,
        ) async {
          calls.add(call);
          return <Object?>[];
        });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_attachmentMediaChannel, null);
  });

  test('remaining picks follow the instance attachment limit', () {
    expect(remainingAttachmentPickLimit(3, maxAttachments: 25), 22);
    expect(remainingAttachmentPickLimit(3, maxAttachments: 2), -1);
  });

  test('the photo picker allows the instance attachment limit', () async {
    await pickNativeGallerySelection(
      attachments: <PendingAttachment>[
        forkUpstream.attachment(1, galleryAssetId: 'asset-a'),
        forkUpstream.attachment(2),
      ],
      maxAttachments: 25,
    );

    expect(calls.single.method, 'pick');
    expect(calls.single.arguments, <String, Object>{
      'limit': 24,
      'selected': <String>['asset-a'],
    });
  });
}
