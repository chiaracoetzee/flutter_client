part of 'user_settings_view_model.dart';

Map<String, Object?> buildCurrentUserProfileUpdatePayload(
  UserSettingsViewState state,
) {
  final json = <String, Object?>{};

  if (state.isEditedDisplayNameSet &&
      state.editedDisplayName != state.displayName) {
    json['global_name'] = state.editedDisplayName;
  }

  if (state.isEditedBioSet && state.editedBio != state.bio) {
    json['bio'] = state.editedBio;
  }

  if (state.isEditedPronounsSet && state.editedPronouns != state.pronouns) {
    json['pronouns'] = state.editedPronouns;
  }

  if (state.isEditedAccentColorSet &&
      state.editedAccentColor != state.accentColor) {
    json['accent_color'] = state.editedAccentColor;
  }

  if (state.editedAvatarBase64 != null) {
    json['avatar'] = state.editedAvatarBase64;
  } else if (state.avatarCleared) {
    json['avatar'] = null;
  }

  if (state.editedBannerBase64 != null) {
    json['banner'] = state.editedBannerBase64;
  } else if (state.bannerCleared) {
    json['banner'] = null;
  }

  if (state.isEditedPremiumBadgeHiddenSet &&
      state.editedPremiumBadgeHidden != state.premiumBadgeHidden) {
    json['premium_badge_hidden'] = state.editedPremiumBadgeHidden;
  }

  if (state.isEditedPremiumBadgeMaskedSet &&
      state.editedPremiumBadgeMasked != state.premiumBadgeMasked) {
    json['premium_badge_masked'] = state.editedPremiumBadgeMasked;
  }

  if (state.isEditedPremiumBadgeTimestampHiddenSet &&
      state.editedPremiumBadgeTimestampHidden !=
          state.premiumBadgeTimestampHidden) {
    json['premium_badge_timestamp_hidden'] =
        state.editedPremiumBadgeTimestampHidden;
  }

  if (state.isEditedPremiumBadgeSequenceHiddenSet &&
      state.editedPremiumBadgeSequenceHidden !=
          state.premiumBadgeSequenceHidden) {
    json['premium_badge_sequence_hidden'] =
        state.editedPremiumBadgeSequenceHidden;
  }

  return json;
}

Map<String, Object?> buildGuildMemberProfileUpdatePayload(
  UserSettingsViewState state, {
  required int profileFlags,
}) {
  final json = <String, Object?>{
    'bio': state.isEditedGuildBioSet ? state.editedGuildBio : state.guildBio,
    'pronouns': state.isEditedGuildPronounsSet
        ? state.editedGuildPronouns
        : state.guildPronouns,
    'accent_color': state.isEditedGuildAccentColorSet
        ? state.editedGuildAccentColor
        : state.guildAccentColor,
  };

  if (state.canChangeNickname) {
    json['nick'] = state.isEditedNickSet ? state.editedNick : state.guildNick;
  }

  if (state.guildAvatarMode == GuildAssetMode.inherit ||
      state.guildAvatarMode == GuildAssetMode.unset) {
    json['avatar'] = null;
  } else if (state.editedGuildAvatarBase64 != null) {
    json['avatar'] = state.editedGuildAvatarBase64;
  }

  if (state.guildBannerMode == GuildAssetMode.inherit ||
      state.guildBannerMode == GuildAssetMode.unset) {
    json['banner'] = null;
  } else if (state.editedGuildBannerBase64 != null) {
    json['banner'] = state.editedGuildBannerBase64;
  }

  if (profileFlags != 0) {
    json['profile_flags'] = profileFlags;
  }

  return json;
}
