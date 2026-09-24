void putPatchImageField(
  Map<String, Object?> json,
  String key, {
  required String? pendingDataUri,
  required bool cleared,
}) {
  if (cleared) {
    json[key] = null;
    return;
  }
  if (pendingDataUri != null) {
    json[key] = pendingDataUri;
  }
}

Map<String, Object?> buildWebhookUpdatePayload({
  String? name,
  String? avatar,
  String? channelId,
}) {
  final json = <String, Object?>{};
  if (name != null) {
    json['name'] = name;
  }
  if (channelId != null) {
    json['channel_id'] = channelId;
  }
  if (avatar != null) {
    json['avatar'] = avatar.isEmpty ? null : avatar;
  }
  return json;
}
