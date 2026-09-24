import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/shared/utils/sdk_patch_json.dart';
import 'package:fluxer_dart/export.dart';

void main() {
  test('buildWebhookUpdatePayload omits avatar when unchanged', () {
    final json = buildWebhookUpdatePayload(name: 'hooks');
    final body = WebhookUpdateRequest.fromJson(json);
    expect(body.toJson().containsKey('avatar'), isFalse);
    expect(body.toJson()['name'], 'hooks');
  });

  test('putPatchImageField only adds image keys when needed', () {
    final json = <String, Object?>{'name': 'guild'};
    putPatchImageField(
      json,
      'icon',
      pendingDataUri: null,
      cleared: false,
    );
    expect(json.containsKey('icon'), isFalse);

    putPatchImageField(
      json,
      'banner',
      pendingDataUri: 'data:image/png;base64,abc',
      cleared: false,
    );
    expect(json['banner'], 'data:image/png;base64,abc');
  });
}
