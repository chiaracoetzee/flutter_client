class RecentChannelVisit {
  const RecentChannelVisit({required this.channelId, this.guildId});

  final String channelId;
  final String? guildId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'channelId': channelId,
    if (guildId != null) 'guildId': guildId,
  };

  factory RecentChannelVisit.fromJson(Map<String, dynamic> json) {
    return RecentChannelVisit(
      channelId: json['channelId'] as String,
      guildId: json['guildId'] as String?,
    );
  }
}

const int kMaxRecentChannelVisits = 20;
