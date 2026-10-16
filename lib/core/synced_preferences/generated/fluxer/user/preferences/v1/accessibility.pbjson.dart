// This is a generated file - do not edit.
//
// Generated from fluxer/user/preferences/v1/accessibility.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use channelTypingIndicatorModeDescriptor instead')
const ChannelTypingIndicatorMode$json = {
  '1': 'ChannelTypingIndicatorMode',
  '2': [
    {'1': 'CHANNEL_TYPING_INDICATOR_MODE_UNSPECIFIED', '2': 0},
    {'1': 'CHANNEL_TYPING_INDICATOR_MODE_AVATARS', '2': 1},
    {'1': 'CHANNEL_TYPING_INDICATOR_MODE_INDICATOR_ONLY', '2': 2},
    {'1': 'CHANNEL_TYPING_INDICATOR_MODE_HIDDEN', '2': 3},
  ],
};

/// Descriptor for `ChannelTypingIndicatorMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List channelTypingIndicatorModeDescriptor = $convert.base64Decode(
    'ChpDaGFubmVsVHlwaW5nSW5kaWNhdG9yTW9kZRItCilDSEFOTkVMX1RZUElOR19JTkRJQ0FUT1'
    'JfTU9ERV9VTlNQRUNJRklFRBAAEikKJUNIQU5ORUxfVFlQSU5HX0lORElDQVRPUl9NT0RFX0FW'
    'QVRBUlMQARIwCixDSEFOTkVMX1RZUElOR19JTkRJQ0FUT1JfTU9ERV9JTkRJQ0FUT1JfT05MWR'
    'ACEigKJENIQU5ORUxfVFlQSU5HX0lORElDQVRPUl9NT0RFX0hJRERFThAD');

@$core.Deprecated('Use mediaDimensionSizeDescriptor instead')
const MediaDimensionSize$json = {
  '1': 'MediaDimensionSize',
  '2': [
    {'1': 'MEDIA_DIMENSION_SIZE_UNSPECIFIED', '2': 0},
    {'1': 'MEDIA_DIMENSION_SIZE_SMALL', '2': 1},
    {'1': 'MEDIA_DIMENSION_SIZE_LARGE', '2': 2},
  ],
};

/// Descriptor for `MediaDimensionSize`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List mediaDimensionSizeDescriptor = $convert.base64Decode(
    'ChJNZWRpYURpbWVuc2lvblNpemUSJAogTUVESUFfRElNRU5TSU9OX1NJWkVfVU5TUEVDSUZJRU'
    'QQABIeChpNRURJQV9ESU1FTlNJT05fU0laRV9TTUFMTBABEh4KGk1FRElBX0RJTUVOU0lPTl9T'
    'SVpFX0xBUkdFEAI=');

@$core.Deprecated('Use dmMessagePreviewModeDescriptor instead')
const DmMessagePreviewMode$json = {
  '1': 'DmMessagePreviewMode',
  '2': [
    {'1': 'DM_MESSAGE_PREVIEW_MODE_UNSPECIFIED', '2': 0},
    {'1': 'DM_MESSAGE_PREVIEW_MODE_ALL', '2': 1},
    {'1': 'DM_MESSAGE_PREVIEW_MODE_UNREAD_ONLY', '2': 2},
    {'1': 'DM_MESSAGE_PREVIEW_MODE_NONE', '2': 3},
  ],
};

/// Descriptor for `DmMessagePreviewMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List dmMessagePreviewModeDescriptor = $convert.base64Decode(
    'ChREbU1lc3NhZ2VQcmV2aWV3TW9kZRInCiNETV9NRVNTQUdFX1BSRVZJRVdfTU9ERV9VTlNQRU'
    'NJRklFRBAAEh8KG0RNX01FU1NBR0VfUFJFVklFV19NT0RFX0FMTBABEicKI0RNX01FU1NBR0Vf'
    'UFJFVklFV19NT0RFX1VOUkVBRF9PTkxZEAISIAocRE1fTUVTU0FHRV9QUkVWSUVXX01PREVfTk'
    '9ORRAD');

@$core.Deprecated('Use hdrDisplayModeDescriptor instead')
const HdrDisplayMode$json = {
  '1': 'HdrDisplayMode',
  '2': [
    {'1': 'HDR_DISPLAY_MODE_UNSPECIFIED', '2': 0},
    {'1': 'HDR_DISPLAY_MODE_FULL', '2': 1},
    {'1': 'HDR_DISPLAY_MODE_STANDARD', '2': 2},
  ],
};

/// Descriptor for `HdrDisplayMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List hdrDisplayModeDescriptor = $convert.base64Decode(
    'Cg5IZHJEaXNwbGF5TW9kZRIgChxIRFJfRElTUExBWV9NT0RFX1VOU1BFQ0lGSUVEEAASGQoVSE'
    'RSX0RJU1BMQVlfTU9ERV9GVUxMEAESHQoZSERSX0RJU1BMQVlfTU9ERV9TVEFOREFSRBAC');

@$core.Deprecated('Use accessibilitySettingsDescriptor instead')
const AccessibilitySettings$json = {
  '1': 'AccessibilitySettings',
  '2': [
    {
      '1': 'show_alt_text_on_images',
      '3': 2223,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'showAltTextOnImages',
      '17': true
    },
    {
      '1': 'mobile_font_size',
      '3': 2224,
      '4': 1,
      '5': 1,
      '9': 1,
      '10': 'mobileFontSize',
      '17': true
    },
    {
      '1': 'mobile_message_group_spacing',
      '3': 2225,
      '4': 1,
      '5': 1,
      '9': 2,
      '10': 'mobileMessageGroupSpacing',
      '17': true
    },
    {
      '1': 'mobile_compact_message_group_spacing',
      '3': 2226,
      '4': 1,
      '5': 1,
      '9': 3,
      '10': 'mobileCompactMessageGroupSpacing',
      '17': true
    },
    {
      '1': 'saturation_factor',
      '3': 1,
      '4': 1,
      '5': 1,
      '9': 4,
      '10': 'saturationFactor',
      '17': true
    },
    {
      '1': 'always_underline_links',
      '3': 2,
      '4': 1,
      '5': 8,
      '10': 'alwaysUnderlineLinks'
    },
    {
      '1': 'enable_text_selection',
      '3': 3,
      '4': 1,
      '5': 8,
      '9': 5,
      '10': 'enableTextSelection',
      '17': true
    },
    {
      '1': 'show_message_send_button',
      '3': 4,
      '4': 1,
      '5': 8,
      '9': 6,
      '10': 'showMessageSendButton',
      '17': true
    },
    {
      '1': 'show_textarea_focus_ring',
      '3': 5,
      '4': 1,
      '5': 8,
      '9': 7,
      '10': 'showTextareaFocusRing',
      '17': true
    },
    {
      '1': 'hide_keyboard_hints',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'hideKeyboardHints'
    },
    {
      '1': 'escape_exits_keyboard_mode',
      '3': 7,
      '4': 1,
      '5': 8,
      '9': 8,
      '10': 'escapeExitsKeyboardMode',
      '17': true
    },
    {
      '1': 'sync_reduced_motion_with_system',
      '3': 8,
      '4': 1,
      '5': 8,
      '9': 9,
      '10': 'syncReducedMotionWithSystem',
      '17': true
    },
    {
      '1': 'reduced_motion_override',
      '3': 9,
      '4': 1,
      '5': 8,
      '9': 10,
      '10': 'reducedMotionOverride',
      '17': true
    },
    {
      '1': 'message_group_spacing',
      '3': 10,
      '4': 1,
      '5': 1,
      '9': 11,
      '10': 'messageGroupSpacing',
      '17': true
    },
    {
      '1': 'message_gutter',
      '3': 11,
      '4': 1,
      '5': 1,
      '9': 12,
      '10': 'messageGutter',
      '17': true
    },
    {
      '1': 'font_size',
      '3': 12,
      '4': 1,
      '5': 1,
      '9': 13,
      '10': 'fontSize',
      '17': true
    },
    {
      '1': 'show_user_avatars_in_compact_mode',
      '3': 13,
      '4': 1,
      '5': 8,
      '9': 14,
      '10': 'showUserAvatarsInCompactMode',
      '17': true
    },
    {
      '1': 'mobile_sticker_animation_overridden',
      '3': 14,
      '4': 1,
      '5': 8,
      '10': 'mobileStickerAnimationOverridden'
    },
    {
      '1': 'mobile_gif_autoplay_overridden',
      '3': 15,
      '4': 1,
      '5': 8,
      '10': 'mobileGifAutoplayOverridden'
    },
    {
      '1': 'mobile_animate_emoji_overridden',
      '3': 16,
      '4': 1,
      '5': 8,
      '10': 'mobileAnimateEmojiOverridden'
    },
    {
      '1': 'mobile_sticker_animation_value',
      '3': 17,
      '4': 1,
      '5': 5,
      '9': 15,
      '10': 'mobileStickerAnimationValue',
      '17': true
    },
    {
      '1': 'mobile_gif_autoplay_value',
      '3': 18,
      '4': 1,
      '5': 8,
      '9': 16,
      '10': 'mobileGifAutoplayValue',
      '17': true
    },
    {
      '1': 'mobile_animate_emoji_value',
      '3': 19,
      '4': 1,
      '5': 8,
      '9': 17,
      '10': 'mobileAnimateEmojiValue',
      '17': true
    },
    {
      '1': 'auto_send_klipy_gifs',
      '3': 20,
      '4': 1,
      '5': 8,
      '10': 'autoSendKlipyGifs'
    },
    {
      '1': 'show_gif_button',
      '3': 21,
      '4': 1,
      '5': 8,
      '9': 18,
      '10': 'showGifButton',
      '17': true
    },
    {
      '1': 'show_memes_button',
      '3': 22,
      '4': 1,
      '5': 8,
      '9': 19,
      '10': 'showMemesButton',
      '17': true
    },
    {
      '1': 'show_stickers_button',
      '3': 23,
      '4': 1,
      '5': 8,
      '9': 20,
      '10': 'showStickersButton',
      '17': true
    },
    {
      '1': 'show_emoji_button',
      '3': 24,
      '4': 1,
      '5': 8,
      '9': 21,
      '10': 'showEmojiButton',
      '17': true
    },
    {
      '1': 'show_media_favorite_button',
      '3': 25,
      '4': 1,
      '5': 8,
      '9': 22,
      '10': 'showMediaFavoriteButton',
      '17': true
    },
    {
      '1': 'show_media_download_button',
      '3': 26,
      '4': 1,
      '5': 8,
      '9': 23,
      '10': 'showMediaDownloadButton',
      '17': true
    },
    {
      '1': 'show_media_delete_button',
      '3': 27,
      '4': 1,
      '5': 8,
      '9': 24,
      '10': 'showMediaDeleteButton',
      '17': true
    },
    {
      '1': 'show_suppress_embeds_button',
      '3': 28,
      '4': 1,
      '5': 8,
      '9': 25,
      '10': 'showSuppressEmbedsButton',
      '17': true
    },
    {
      '1': 'show_gif_indicator',
      '3': 29,
      '4': 1,
      '5': 8,
      '9': 26,
      '10': 'showGifIndicator',
      '17': true
    },
    {
      '1': 'show_attachment_expiry_indicator',
      '3': 30,
      '4': 1,
      '5': 8,
      '9': 27,
      '10': 'showAttachmentExpiryIndicator',
      '17': true
    },
    {
      '1': 'use_browser_locale_for_time_format',
      '3': 31,
      '4': 1,
      '5': 8,
      '9': 28,
      '10': 'useBrowserLocaleForTimeFormat',
      '17': true
    },
    {
      '1': 'channel_typing_indicator_mode',
      '3': 32,
      '4': 1,
      '5': 14,
      '6': '.fluxer.user.preferences.v1.ChannelTypingIndicatorMode',
      '10': 'channelTypingIndicatorMode'
    },
    {
      '1': 'show_selected_channel_typing_indicator',
      '3': 33,
      '4': 1,
      '5': 8,
      '9': 29,
      '10': 'showSelectedChannelTypingIndicator',
      '17': true
    },
    {
      '1': 'show_message_action_bar',
      '3': 34,
      '4': 1,
      '5': 8,
      '9': 30,
      '10': 'showMessageActionBar',
      '17': true
    },
    {
      '1': 'show_message_action_bar_quick_reactions',
      '3': 35,
      '4': 1,
      '5': 8,
      '9': 31,
      '10': 'showMessageActionBarQuickReactions',
      '17': true
    },
    {
      '1': 'show_message_action_bar_shift_expand',
      '3': 36,
      '4': 1,
      '5': 8,
      '9': 32,
      '10': 'showMessageActionBarShiftExpand',
      '17': true
    },
    {
      '1': 'show_message_action_bar_only_more_button',
      '3': 37,
      '4': 1,
      '5': 8,
      '9': 33,
      '10': 'showMessageActionBarOnlyMoreButton',
      '17': true
    },
    {
      '1': 'show_default_emojis_in_autocomplete',
      '3': 38,
      '4': 1,
      '5': 8,
      '9': 34,
      '10': 'showDefaultEmojisInAutocomplete',
      '17': true
    },
    {
      '1': 'show_custom_emojis_in_autocomplete',
      '3': 39,
      '4': 1,
      '5': 8,
      '9': 35,
      '10': 'showCustomEmojisInAutocomplete',
      '17': true
    },
    {
      '1': 'show_stickers_in_autocomplete',
      '3': 40,
      '4': 1,
      '5': 8,
      '9': 36,
      '10': 'showStickersInAutocomplete',
      '17': true
    },
    {
      '1': 'show_memes_in_autocomplete',
      '3': 41,
      '4': 1,
      '5': 8,
      '9': 37,
      '10': 'showMemesInAutocomplete',
      '17': true
    },
    {
      '1': 'attachment_media_dimension_size',
      '3': 42,
      '4': 1,
      '5': 14,
      '6': '.fluxer.user.preferences.v1.MediaDimensionSize',
      '10': 'attachmentMediaDimensionSize'
    },
    {
      '1': 'embed_media_dimension_size',
      '3': 43,
      '4': 1,
      '5': 14,
      '6': '.fluxer.user.preferences.v1.MediaDimensionSize',
      '10': 'embedMediaDimensionSize'
    },
    {
      '1': 'voice_channel_join_requires_double_click',
      '3': 44,
      '4': 1,
      '5': 8,
      '9': 38,
      '10': 'voiceChannelJoinRequiresDoubleClick',
      '17': true
    },
    {
      '1': 'custom_theme_css',
      '3': 45,
      '4': 1,
      '5': 9,
      '9': 39,
      '10': 'customThemeCss',
      '17': true
    },
    {
      '1': 'show_favorites',
      '3': 46,
      '4': 1,
      '5': 8,
      '9': 40,
      '10': 'showFavorites',
      '17': true
    },
    {
      '1': 'zoom_level',
      '3': 47,
      '4': 1,
      '5': 1,
      '9': 41,
      '10': 'zoomLevel',
      '17': true
    },
    {
      '1': 'dm_message_preview_mode',
      '3': 48,
      '4': 1,
      '5': 14,
      '6': '.fluxer.user.preferences.v1.DmMessagePreviewMode',
      '10': 'dmMessagePreviewMode'
    },
    {
      '1': 'enable_tts_command',
      '3': 49,
      '4': 1,
      '5': 8,
      '9': 42,
      '10': 'enableTtsCommand',
      '17': true
    },
    {
      '1': 'tts_rate',
      '3': 50,
      '4': 1,
      '5': 1,
      '9': 43,
      '10': 'ttsRate',
      '17': true
    },
    {
      '1': 'show_faded_unread_on_muted_channels',
      '3': 51,
      '4': 1,
      '5': 8,
      '9': 44,
      '10': 'showFadedUnreadOnMutedChannels',
      '17': true
    },
    {
      '1': 'show_context_menu_shortcuts',
      '3': 52,
      '4': 1,
      '5': 8,
      '9': 45,
      '10': 'showContextMenuShortcuts',
      '17': true
    },
    {
      '1': 'confirm_before_starting_calls',
      '3': 53,
      '4': 1,
      '5': 8,
      '9': 46,
      '10': 'confirmBeforeStartingCalls',
      '17': true
    },
    {
      '1': 'hdr_display_mode',
      '3': 54,
      '4': 1,
      '5': 14,
      '6': '.fluxer.user.preferences.v1.HdrDisplayMode',
      '10': 'hdrDisplayMode'
    },
    {
      '1': 'preserve_edit_draft',
      '3': 55,
      '4': 1,
      '5': 8,
      '9': 47,
      '10': 'preserveEditDraft',
      '17': true
    },
    {
      '1': 'stay_interactive_when_unfocused',
      '3': 56,
      '4': 1,
      '5': 8,
      '9': 48,
      '10': 'stayInteractiveWhenUnfocused',
      '17': true
    },
    {
      '1': 'confirm_before_joining_voice_channels',
      '3': 57,
      '4': 1,
      '5': 8,
      '9': 49,
      '10': 'confirmBeforeJoiningVoiceChannels',
      '17': true
    },
    {
      '1': 'screen_reader_announce_new_messages',
      '3': 58,
      '4': 1,
      '5': 8,
      '9': 50,
      '10': 'screenReaderAnnounceNewMessages',
      '17': true
    },
    {
      '1': 'first_click_pass_through_when_unfocused',
      '3': 59,
      '4': 1,
      '5': 8,
      '9': 51,
      '10': 'firstClickPassThroughWhenUnfocused',
      '17': true
    },
    {
      '1': 'compact_message_group_spacing',
      '3': 60,
      '4': 1,
      '5': 1,
      '9': 52,
      '10': 'compactMessageGroupSpacing',
      '17': true
    },
    {
      '1': 'scroll_to_bottom_on_message_send',
      '3': 61,
      '4': 1,
      '5': 8,
      '9': 53,
      '10': 'scrollToBottomOnMessageSend',
      '17': true
    },
    {
      '1': 'dim_strikethrough_text',
      '3': 62,
      '4': 1,
      '5': 8,
      '9': 54,
      '10': 'dimStrikethroughText',
      '17': true
    },
    {
      '1': 'sequential_file_send',
      '3': 63,
      '4': 1,
      '5': 8,
      '9': 55,
      '10': 'sequentialFileSend',
      '17': true
    },
    {
      '1': 'mobile_splash_zoom_animation',
      '3': 64,
      '4': 1,
      '5': 8,
      '9': 56,
      '10': 'mobileSplashZoomAnimation',
      '17': true
    },
  ],
  '8': [
    {'1': '_show_alt_text_on_images'},
    {'1': '_mobile_font_size'},
    {'1': '_mobile_message_group_spacing'},
    {'1': '_mobile_compact_message_group_spacing'},
    {'1': '_saturation_factor'},
    {'1': '_enable_text_selection'},
    {'1': '_show_message_send_button'},
    {'1': '_show_textarea_focus_ring'},
    {'1': '_escape_exits_keyboard_mode'},
    {'1': '_sync_reduced_motion_with_system'},
    {'1': '_reduced_motion_override'},
    {'1': '_message_group_spacing'},
    {'1': '_message_gutter'},
    {'1': '_font_size'},
    {'1': '_show_user_avatars_in_compact_mode'},
    {'1': '_mobile_sticker_animation_value'},
    {'1': '_mobile_gif_autoplay_value'},
    {'1': '_mobile_animate_emoji_value'},
    {'1': '_show_gif_button'},
    {'1': '_show_memes_button'},
    {'1': '_show_stickers_button'},
    {'1': '_show_emoji_button'},
    {'1': '_show_media_favorite_button'},
    {'1': '_show_media_download_button'},
    {'1': '_show_media_delete_button'},
    {'1': '_show_suppress_embeds_button'},
    {'1': '_show_gif_indicator'},
    {'1': '_show_attachment_expiry_indicator'},
    {'1': '_use_browser_locale_for_time_format'},
    {'1': '_show_selected_channel_typing_indicator'},
    {'1': '_show_message_action_bar'},
    {'1': '_show_message_action_bar_quick_reactions'},
    {'1': '_show_message_action_bar_shift_expand'},
    {'1': '_show_message_action_bar_only_more_button'},
    {'1': '_show_default_emojis_in_autocomplete'},
    {'1': '_show_custom_emojis_in_autocomplete'},
    {'1': '_show_stickers_in_autocomplete'},
    {'1': '_show_memes_in_autocomplete'},
    {'1': '_voice_channel_join_requires_double_click'},
    {'1': '_custom_theme_css'},
    {'1': '_show_favorites'},
    {'1': '_zoom_level'},
    {'1': '_enable_tts_command'},
    {'1': '_tts_rate'},
    {'1': '_show_faded_unread_on_muted_channels'},
    {'1': '_show_context_menu_shortcuts'},
    {'1': '_confirm_before_starting_calls'},
    {'1': '_preserve_edit_draft'},
    {'1': '_stay_interactive_when_unfocused'},
    {'1': '_confirm_before_joining_voice_channels'},
    {'1': '_screen_reader_announce_new_messages'},
    {'1': '_first_click_pass_through_when_unfocused'},
    {'1': '_compact_message_group_spacing'},
    {'1': '_scroll_to_bottom_on_message_send'},
    {'1': '_dim_strikethrough_text'},
    {'1': '_sequential_file_send'},
    {'1': '_mobile_splash_zoom_animation'},
  ],
};

/// Descriptor for `AccessibilitySettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accessibilitySettingsDescriptor = $convert.base64Decode(
    'ChVBY2Nlc3NpYmlsaXR5U2V0dGluZ3MSOgoXc2hvd19hbHRfdGV4dF9vbl9pbWFnZXMYrxEgAS'
    'gISABSE3Nob3dBbHRUZXh0T25JbWFnZXOIAQESLgoQbW9iaWxlX2ZvbnRfc2l6ZRiwESABKAFI'
    'AVIObW9iaWxlRm9udFNpemWIAQESRQocbW9iaWxlX21lc3NhZ2VfZ3JvdXBfc3BhY2luZxixES'
    'ABKAFIAlIZbW9iaWxlTWVzc2FnZUdyb3VwU3BhY2luZ4gBARJUCiRtb2JpbGVfY29tcGFjdF9t'
    'ZXNzYWdlX2dyb3VwX3NwYWNpbmcYshEgASgBSANSIG1vYmlsZUNvbXBhY3RNZXNzYWdlR3JvdX'
    'BTcGFjaW5niAEBEjAKEXNhdHVyYXRpb25fZmFjdG9yGAEgASgBSARSEHNhdHVyYXRpb25GYWN0'
    'b3KIAQESNAoWYWx3YXlzX3VuZGVybGluZV9saW5rcxgCIAEoCFIUYWx3YXlzVW5kZXJsaW5lTG'
    'lua3MSNwoVZW5hYmxlX3RleHRfc2VsZWN0aW9uGAMgASgISAVSE2VuYWJsZVRleHRTZWxlY3Rp'
    'b26IAQESPAoYc2hvd19tZXNzYWdlX3NlbmRfYnV0dG9uGAQgASgISAZSFXNob3dNZXNzYWdlU2'
    'VuZEJ1dHRvbogBARI8ChhzaG93X3RleHRhcmVhX2ZvY3VzX3JpbmcYBSABKAhIB1IVc2hvd1Rl'
    'eHRhcmVhRm9jdXNSaW5niAEBEi4KE2hpZGVfa2V5Ym9hcmRfaGludHMYBiABKAhSEWhpZGVLZX'
    'lib2FyZEhpbnRzEkAKGmVzY2FwZV9leGl0c19rZXlib2FyZF9tb2RlGAcgASgISAhSF2VzY2Fw'
    'ZUV4aXRzS2V5Ym9hcmRNb2RliAEBEkkKH3N5bmNfcmVkdWNlZF9tb3Rpb25fd2l0aF9zeXN0ZW'
    '0YCCABKAhICVIbc3luY1JlZHVjZWRNb3Rpb25XaXRoU3lzdGVtiAEBEjsKF3JlZHVjZWRfbW90'
    'aW9uX292ZXJyaWRlGAkgASgISApSFXJlZHVjZWRNb3Rpb25PdmVycmlkZYgBARI3ChVtZXNzYW'
    'dlX2dyb3VwX3NwYWNpbmcYCiABKAFIC1ITbWVzc2FnZUdyb3VwU3BhY2luZ4gBARIqCg5tZXNz'
    'YWdlX2d1dHRlchgLIAEoAUgMUg1tZXNzYWdlR3V0dGVyiAEBEiAKCWZvbnRfc2l6ZRgMIAEoAU'
    'gNUghmb250U2l6ZYgBARJMCiFzaG93X3VzZXJfYXZhdGFyc19pbl9jb21wYWN0X21vZGUYDSAB'
    'KAhIDlIcc2hvd1VzZXJBdmF0YXJzSW5Db21wYWN0TW9kZYgBARJNCiNtb2JpbGVfc3RpY2tlcl'
    '9hbmltYXRpb25fb3ZlcnJpZGRlbhgOIAEoCFIgbW9iaWxlU3RpY2tlckFuaW1hdGlvbk92ZXJy'
    'aWRkZW4SQwoebW9iaWxlX2dpZl9hdXRvcGxheV9vdmVycmlkZGVuGA8gASgIUhttb2JpbGVHaW'
    'ZBdXRvcGxheU92ZXJyaWRkZW4SRQofbW9iaWxlX2FuaW1hdGVfZW1vamlfb3ZlcnJpZGRlbhgQ'
    'IAEoCFIcbW9iaWxlQW5pbWF0ZUVtb2ppT3ZlcnJpZGRlbhJICh5tb2JpbGVfc3RpY2tlcl9hbm'
    'ltYXRpb25fdmFsdWUYESABKAVID1IbbW9iaWxlU3RpY2tlckFuaW1hdGlvblZhbHVliAEBEj4K'
    'GW1vYmlsZV9naWZfYXV0b3BsYXlfdmFsdWUYEiABKAhIEFIWbW9iaWxlR2lmQXV0b3BsYXlWYW'
    'x1ZYgBARJAChptb2JpbGVfYW5pbWF0ZV9lbW9qaV92YWx1ZRgTIAEoCEgRUhdtb2JpbGVBbmlt'
    'YXRlRW1vamlWYWx1ZYgBARIvChRhdXRvX3NlbmRfa2xpcHlfZ2lmcxgUIAEoCFIRYXV0b1Nlbm'
    'RLbGlweUdpZnMSKwoPc2hvd19naWZfYnV0dG9uGBUgASgISBJSDXNob3dHaWZCdXR0b26IAQES'
    'LwoRc2hvd19tZW1lc19idXR0b24YFiABKAhIE1IPc2hvd01lbWVzQnV0dG9uiAEBEjUKFHNob3'
    'dfc3RpY2tlcnNfYnV0dG9uGBcgASgISBRSEnNob3dTdGlja2Vyc0J1dHRvbogBARIvChFzaG93'
    'X2Vtb2ppX2J1dHRvbhgYIAEoCEgVUg9zaG93RW1vamlCdXR0b26IAQESQAoac2hvd19tZWRpYV'
    '9mYXZvcml0ZV9idXR0b24YGSABKAhIFlIXc2hvd01lZGlhRmF2b3JpdGVCdXR0b26IAQESQAoa'
    'c2hvd19tZWRpYV9kb3dubG9hZF9idXR0b24YGiABKAhIF1IXc2hvd01lZGlhRG93bmxvYWRCdX'
    'R0b26IAQESPAoYc2hvd19tZWRpYV9kZWxldGVfYnV0dG9uGBsgASgISBhSFXNob3dNZWRpYURl'
    'bGV0ZUJ1dHRvbogBARJCChtzaG93X3N1cHByZXNzX2VtYmVkc19idXR0b24YHCABKAhIGVIYc2'
    'hvd1N1cHByZXNzRW1iZWRzQnV0dG9uiAEBEjEKEnNob3dfZ2lmX2luZGljYXRvchgdIAEoCEga'
    'UhBzaG93R2lmSW5kaWNhdG9yiAEBEkwKIHNob3dfYXR0YWNobWVudF9leHBpcnlfaW5kaWNhdG'
    '9yGB4gASgISBtSHXNob3dBdHRhY2htZW50RXhwaXJ5SW5kaWNhdG9yiAEBEk4KInVzZV9icm93'
    'c2VyX2xvY2FsZV9mb3JfdGltZV9mb3JtYXQYHyABKAhIHFIddXNlQnJvd3NlckxvY2FsZUZvcl'
    'RpbWVGb3JtYXSIAQESeQodY2hhbm5lbF90eXBpbmdfaW5kaWNhdG9yX21vZGUYICABKA4yNi5m'
    'bHV4ZXIudXNlci5wcmVmZXJlbmNlcy52MS5DaGFubmVsVHlwaW5nSW5kaWNhdG9yTW9kZVIaY2'
    'hhbm5lbFR5cGluZ0luZGljYXRvck1vZGUSVwomc2hvd19zZWxlY3RlZF9jaGFubmVsX3R5cGlu'
    'Z19pbmRpY2F0b3IYISABKAhIHVIic2hvd1NlbGVjdGVkQ2hhbm5lbFR5cGluZ0luZGljYXRvco'
    'gBARI6ChdzaG93X21lc3NhZ2VfYWN0aW9uX2JhchgiIAEoCEgeUhRzaG93TWVzc2FnZUFjdGlv'
    'bkJhcogBARJYCidzaG93X21lc3NhZ2VfYWN0aW9uX2Jhcl9xdWlja19yZWFjdGlvbnMYIyABKA'
    'hIH1Iic2hvd01lc3NhZ2VBY3Rpb25CYXJRdWlja1JlYWN0aW9uc4gBARJSCiRzaG93X21lc3Nh'
    'Z2VfYWN0aW9uX2Jhcl9zaGlmdF9leHBhbmQYJCABKAhIIFIfc2hvd01lc3NhZ2VBY3Rpb25CYX'
    'JTaGlmdEV4cGFuZIgBARJZCihzaG93X21lc3NhZ2VfYWN0aW9uX2Jhcl9vbmx5X21vcmVfYnV0'
    'dG9uGCUgASgISCFSInNob3dNZXNzYWdlQWN0aW9uQmFyT25seU1vcmVCdXR0b26IAQESUQojc2'
    'hvd19kZWZhdWx0X2Vtb2ppc19pbl9hdXRvY29tcGxldGUYJiABKAhIIlIfc2hvd0RlZmF1bHRF'
    'bW9qaXNJbkF1dG9jb21wbGV0ZYgBARJPCiJzaG93X2N1c3RvbV9lbW9qaXNfaW5fYXV0b2NvbX'
    'BsZXRlGCcgASgISCNSHnNob3dDdXN0b21FbW9qaXNJbkF1dG9jb21wbGV0ZYgBARJGCh1zaG93'
    'X3N0aWNrZXJzX2luX2F1dG9jb21wbGV0ZRgoIAEoCEgkUhpzaG93U3RpY2tlcnNJbkF1dG9jb2'
    '1wbGV0ZYgBARJAChpzaG93X21lbWVzX2luX2F1dG9jb21wbGV0ZRgpIAEoCEglUhdzaG93TWVt'
    'ZXNJbkF1dG9jb21wbGV0ZYgBARJ1Ch9hdHRhY2htZW50X21lZGlhX2RpbWVuc2lvbl9zaXplGC'
    'ogASgOMi4uZmx1eGVyLnVzZXIucHJlZmVyZW5jZXMudjEuTWVkaWFEaW1lbnNpb25TaXplUhxh'
    'dHRhY2htZW50TWVkaWFEaW1lbnNpb25TaXplEmsKGmVtYmVkX21lZGlhX2RpbWVuc2lvbl9zaX'
    'plGCsgASgOMi4uZmx1eGVyLnVzZXIucHJlZmVyZW5jZXMudjEuTWVkaWFEaW1lbnNpb25TaXpl'
    'UhdlbWJlZE1lZGlhRGltZW5zaW9uU2l6ZRJaCih2b2ljZV9jaGFubmVsX2pvaW5fcmVxdWlyZX'
    'NfZG91YmxlX2NsaWNrGCwgASgISCZSI3ZvaWNlQ2hhbm5lbEpvaW5SZXF1aXJlc0RvdWJsZUNs'
    'aWNriAEBEi0KEGN1c3RvbV90aGVtZV9jc3MYLSABKAlIJ1IOY3VzdG9tVGhlbWVDc3OIAQESKg'
    'oOc2hvd19mYXZvcml0ZXMYLiABKAhIKFINc2hvd0Zhdm9yaXRlc4gBARIiCgp6b29tX2xldmVs'
    'GC8gASgBSClSCXpvb21MZXZlbIgBARJnChdkbV9tZXNzYWdlX3ByZXZpZXdfbW9kZRgwIAEoDj'
    'IwLmZsdXhlci51c2VyLnByZWZlcmVuY2VzLnYxLkRtTWVzc2FnZVByZXZpZXdNb2RlUhRkbU1l'
    'c3NhZ2VQcmV2aWV3TW9kZRIxChJlbmFibGVfdHRzX2NvbW1hbmQYMSABKAhIKlIQZW5hYmxlVH'
    'RzQ29tbWFuZIgBARIeCgh0dHNfcmF0ZRgyIAEoAUgrUgd0dHNSYXRliAEBElAKI3Nob3dfZmFk'
    'ZWRfdW5yZWFkX29uX211dGVkX2NoYW5uZWxzGDMgASgISCxSHnNob3dGYWRlZFVucmVhZE9uTX'
    'V0ZWRDaGFubmVsc4gBARJCChtzaG93X2NvbnRleHRfbWVudV9zaG9ydGN1dHMYNCABKAhILVIY'
    'c2hvd0NvbnRleHRNZW51U2hvcnRjdXRziAEBEkYKHWNvbmZpcm1fYmVmb3JlX3N0YXJ0aW5nX2'
    'NhbGxzGDUgASgISC5SGmNvbmZpcm1CZWZvcmVTdGFydGluZ0NhbGxziAEBElQKEGhkcl9kaXNw'
    'bGF5X21vZGUYNiABKA4yKi5mbHV4ZXIudXNlci5wcmVmZXJlbmNlcy52MS5IZHJEaXNwbGF5TW'
    '9kZVIOaGRyRGlzcGxheU1vZGUSMwoTcHJlc2VydmVfZWRpdF9kcmFmdBg3IAEoCEgvUhFwcmVz'
    'ZXJ2ZUVkaXREcmFmdIgBARJKCh9zdGF5X2ludGVyYWN0aXZlX3doZW5fdW5mb2N1c2VkGDggAS'
    'gISDBSHHN0YXlJbnRlcmFjdGl2ZVdoZW5VbmZvY3VzZWSIAQESVQolY29uZmlybV9iZWZvcmVf'
    'am9pbmluZ192b2ljZV9jaGFubmVscxg5IAEoCEgxUiFjb25maXJtQmVmb3JlSm9pbmluZ1ZvaW'
    'NlQ2hhbm5lbHOIAQESUQojc2NyZWVuX3JlYWRlcl9hbm5vdW5jZV9uZXdfbWVzc2FnZXMYOiAB'
    'KAhIMlIfc2NyZWVuUmVhZGVyQW5ub3VuY2VOZXdNZXNzYWdlc4gBARJYCidmaXJzdF9jbGlja1'
    '9wYXNzX3Rocm91Z2hfd2hlbl91bmZvY3VzZWQYOyABKAhIM1IiZmlyc3RDbGlja1Bhc3NUaHJv'
    'dWdoV2hlblVuZm9jdXNlZIgBARJGCh1jb21wYWN0X21lc3NhZ2VfZ3JvdXBfc3BhY2luZxg8IA'
    'EoAUg0Uhpjb21wYWN0TWVzc2FnZUdyb3VwU3BhY2luZ4gBARJKCiBzY3JvbGxfdG9fYm90dG9t'
    'X29uX21lc3NhZ2Vfc2VuZBg9IAEoCEg1UhtzY3JvbGxUb0JvdHRvbU9uTWVzc2FnZVNlbmSIAQ'
    'ESOQoWZGltX3N0cmlrZXRocm91Z2hfdGV4dBg+IAEoCEg2UhRkaW1TdHJpa2V0aHJvdWdoVGV4'
    'dIgBARI1ChRzZXF1ZW50aWFsX2ZpbGVfc2VuZBg/IAEoCEg3UhJzZXF1ZW50aWFsRmlsZVNlbm'
    'SIAQESRAocbW9iaWxlX3NwbGFzaF96b29tX2FuaW1hdGlvbhhAIAEoCEg4Uhltb2JpbGVTcGxh'
    'c2hab29tQW5pbWF0aW9uiAEBQhoKGF9zaG93X2FsdF90ZXh0X29uX2ltYWdlc0ITChFfbW9iaW'
    'xlX2ZvbnRfc2l6ZUIfCh1fbW9iaWxlX21lc3NhZ2VfZ3JvdXBfc3BhY2luZ0InCiVfbW9iaWxl'
    'X2NvbXBhY3RfbWVzc2FnZV9ncm91cF9zcGFjaW5nQhQKEl9zYXR1cmF0aW9uX2ZhY3RvckIYCh'
    'ZfZW5hYmxlX3RleHRfc2VsZWN0aW9uQhsKGV9zaG93X21lc3NhZ2Vfc2VuZF9idXR0b25CGwoZ'
    'X3Nob3dfdGV4dGFyZWFfZm9jdXNfcmluZ0IdChtfZXNjYXBlX2V4aXRzX2tleWJvYXJkX21vZG'
    'VCIgogX3N5bmNfcmVkdWNlZF9tb3Rpb25fd2l0aF9zeXN0ZW1CGgoYX3JlZHVjZWRfbW90aW9u'
    'X292ZXJyaWRlQhgKFl9tZXNzYWdlX2dyb3VwX3NwYWNpbmdCEQoPX21lc3NhZ2VfZ3V0dGVyQg'
    'wKCl9mb250X3NpemVCJAoiX3Nob3dfdXNlcl9hdmF0YXJzX2luX2NvbXBhY3RfbW9kZUIhCh9f'
    'bW9iaWxlX3N0aWNrZXJfYW5pbWF0aW9uX3ZhbHVlQhwKGl9tb2JpbGVfZ2lmX2F1dG9wbGF5X3'
    'ZhbHVlQh0KG19tb2JpbGVfYW5pbWF0ZV9lbW9qaV92YWx1ZUISChBfc2hvd19naWZfYnV0dG9u'
    'QhQKEl9zaG93X21lbWVzX2J1dHRvbkIXChVfc2hvd19zdGlja2Vyc19idXR0b25CFAoSX3Nob3'
    'dfZW1vamlfYnV0dG9uQh0KG19zaG93X21lZGlhX2Zhdm9yaXRlX2J1dHRvbkIdChtfc2hvd19t'
    'ZWRpYV9kb3dubG9hZF9idXR0b25CGwoZX3Nob3dfbWVkaWFfZGVsZXRlX2J1dHRvbkIeChxfc2'
    'hvd19zdXBwcmVzc19lbWJlZHNfYnV0dG9uQhUKE19zaG93X2dpZl9pbmRpY2F0b3JCIwohX3No'
    'b3dfYXR0YWNobWVudF9leHBpcnlfaW5kaWNhdG9yQiUKI191c2VfYnJvd3Nlcl9sb2NhbGVfZm'
    '9yX3RpbWVfZm9ybWF0QikKJ19zaG93X3NlbGVjdGVkX2NoYW5uZWxfdHlwaW5nX2luZGljYXRv'
    'ckIaChhfc2hvd19tZXNzYWdlX2FjdGlvbl9iYXJCKgooX3Nob3dfbWVzc2FnZV9hY3Rpb25fYm'
    'FyX3F1aWNrX3JlYWN0aW9uc0InCiVfc2hvd19tZXNzYWdlX2FjdGlvbl9iYXJfc2hpZnRfZXhw'
    'YW5kQisKKV9zaG93X21lc3NhZ2VfYWN0aW9uX2Jhcl9vbmx5X21vcmVfYnV0dG9uQiYKJF9zaG'
    '93X2RlZmF1bHRfZW1vamlzX2luX2F1dG9jb21wbGV0ZUIlCiNfc2hvd19jdXN0b21fZW1vamlz'
    'X2luX2F1dG9jb21wbGV0ZUIgCh5fc2hvd19zdGlja2Vyc19pbl9hdXRvY29tcGxldGVCHQobX3'
    'Nob3dfbWVtZXNfaW5fYXV0b2NvbXBsZXRlQisKKV92b2ljZV9jaGFubmVsX2pvaW5fcmVxdWly'
    'ZXNfZG91YmxlX2NsaWNrQhMKEV9jdXN0b21fdGhlbWVfY3NzQhEKD19zaG93X2Zhdm9yaXRlc0'
    'INCgtfem9vbV9sZXZlbEIVChNfZW5hYmxlX3R0c19jb21tYW5kQgsKCV90dHNfcmF0ZUImCiRf'
    'c2hvd19mYWRlZF91bnJlYWRfb25fbXV0ZWRfY2hhbm5lbHNCHgocX3Nob3dfY29udGV4dF9tZW'
    '51X3Nob3J0Y3V0c0IgCh5fY29uZmlybV9iZWZvcmVfc3RhcnRpbmdfY2FsbHNCFgoUX3ByZXNl'
    'cnZlX2VkaXRfZHJhZnRCIgogX3N0YXlfaW50ZXJhY3RpdmVfd2hlbl91bmZvY3VzZWRCKAomX2'
    'NvbmZpcm1fYmVmb3JlX2pvaW5pbmdfdm9pY2VfY2hhbm5lbHNCJgokX3NjcmVlbl9yZWFkZXJf'
    'YW5ub3VuY2VfbmV3X21lc3NhZ2VzQioKKF9maXJzdF9jbGlja19wYXNzX3Rocm91Z2hfd2hlbl'
    '91bmZvY3VzZWRCIAoeX2NvbXBhY3RfbWVzc2FnZV9ncm91cF9zcGFjaW5nQiMKIV9zY3JvbGxf'
    'dG9fYm90dG9tX29uX21lc3NhZ2Vfc2VuZEIZChdfZGltX3N0cmlrZXRocm91Z2hfdGV4dEIXCh'
    'Vfc2VxdWVudGlhbF9maWxlX3NlbmRCHwodX21vYmlsZV9zcGxhc2hfem9vbV9hbmltYXRpb24=');

@$core.Deprecated('Use accessibilityOverridesDescriptor instead')
const AccessibilityOverrides$json = {
  '1': 'AccessibilityOverrides',
  '2': [
    {
      '1': 'gif_autoplay_dirty',
      '3': 1,
      '4': 1,
      '5': 8,
      '10': 'gifAutoplayDirty'
    },
    {
      '1': 'animate_emoji_dirty',
      '3': 2,
      '4': 1,
      '5': 8,
      '10': 'animateEmojiDirty'
    },
    {
      '1': 'animate_stickers_dirty',
      '3': 3,
      '4': 1,
      '5': 8,
      '10': 'animateStickersDirty'
    },
  ],
};

/// Descriptor for `AccessibilityOverrides`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accessibilityOverridesDescriptor = $convert.base64Decode(
    'ChZBY2Nlc3NpYmlsaXR5T3ZlcnJpZGVzEiwKEmdpZl9hdXRvcGxheV9kaXJ0eRgBIAEoCFIQZ2'
    'lmQXV0b3BsYXlEaXJ0eRIuChNhbmltYXRlX2Vtb2ppX2RpcnR5GAIgASgIUhFhbmltYXRlRW1v'
    'amlEaXJ0eRI0ChZhbmltYXRlX3N0aWNrZXJzX2RpcnR5GAMgASgIUhRhbmltYXRlU3RpY2tlcn'
    'NEaXJ0eQ==');
