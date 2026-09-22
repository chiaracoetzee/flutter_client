class RecentChannelVisit {
  const RecentChannelVisit({
    required this.channelId,
    required this.visitedAt,
    this.guildId,
  });

  final String channelId;
  final String? guildId;
  final DateTime visitedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'channelId': channelId,
    if (guildId != null) 'guildId': guildId,
    'visitedAt': visitedAt.toIso8601String(),
  };

  factory RecentChannelVisit.fromJson(Map<String, dynamic> json) {
    return RecentChannelVisit(
      channelId: json['channelId'] as String,
      guildId: json['guildId'] as String?,
      visitedAt:
          DateTime.tryParse(json['visitedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

const int kMaxRecentChannelVisits = 20;
