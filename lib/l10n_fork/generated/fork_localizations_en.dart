// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ForkLocalizationsEn extends ForkLocalizations {
  ForkLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Change Persona';

  @override
  String get chatAttachmentPanelVoice => 'Voice';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'Quick Switcher button';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Replace the voice message button in the message input with a Quick Switcher button for fast navigation';

  @override
  String get userSettingsCheckForUpdates => 'Check for updates';

  @override
  String get userSettingsCheckingForUpdates => 'Checking for updates…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer is up to date';

  @override
  String get userSettingsUpdateAvailableTitle => 'Update Available';

  @override
  String get userSettingsUpdateDownloadAction => 'Download & Install';

  @override
  String get userSettingsUpdateInstallAction => 'Install Update';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Downloading update ($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed => 'Failed to check or download update.';

  @override
  String get personaSelectTitle => 'Select Persona';

  @override
  String get personaSettingsHeader => 'Persona Settings';

  @override
  String get personaManageAction => 'Manage';

  @override
  String get personaSearchPlaceholder => 'Search personas, tags, pronouns...';

  @override
  String get personaModeManual => 'Manual';

  @override
  String get personaModeLast => 'Last Used';

  @override
  String get personaModeManualDescription =>
      'Always sends as selected persona until changed.';

  @override
  String get personaModeLastDescription =>
      'Auto-switches to the persona used in your last message.';

  @override
  String get personaRecentHeader => 'RECENT PERSONAS';

  @override
  String personaAllHeader(int count) {
    return 'ALL PERSONAS ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'SEARCH RESULTS ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Root Account (Default)';

  @override
  String get personaEmptyState =>
      'No personas configured yet. Create one via Manage Personas.';

  @override
  String get personaEmptySearch => 'No matching personas found.';

  @override
  String get personaEditTitle => 'Edit Persona';

  @override
  String get personaCreateTitle => 'Create Persona';

  @override
  String get personaDisplayNameLabel => 'Display Name';

  @override
  String get personaPronounsLabel => 'Pronouns';

  @override
  String get personaPronounsHint => 'e.g. they/them';

  @override
  String get personaBioHint => 'Tell others about this persona...';

  @override
  String get personaUpdatedToast => 'Persona updated';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Failed to update persona: $error';
  }

  @override
  String get personaSectionTitle => 'Personas';

  @override
  String get personaDisplayNameHint => 'Persona name';

  @override
  String personaSendingAsTag(String name) {
    return 'Sending as $name (Matched by tag)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Sending as $name (Latched)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Sending as @$username';
  }

  @override
  String get personaMainAccount => 'Main account';

  @override
  String get personaEditPersona => 'Edit persona';

  @override
  String get userSettingsNavPersonas => 'Personas';

  @override
  String get personaSettingsDescription =>
      'Configure your active persona mode, custom display tag, and manage individual personas.';

  @override
  String get personaDisplayTagSection => 'Display Tag';

  @override
  String get personaDisplayTagDescription =>
      'Display tag will appear next to all persona names in messages. If no display tag is set, your account profile picture will be shown.';

  @override
  String get personaDisplayTagLabel => 'Display Tag Text';

  @override
  String get personaDisplayTagHint => 'e.g. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Display Tag Icon';

  @override
  String get personaUploadTagIcon => 'Upload Icon';

  @override
  String get personaChangeTagIcon => 'Change Icon';

  @override
  String get personaRemoveTagIcon => 'Remove Icon';

  @override
  String get personaChatPreviewTitle => 'Chat Preview';

  @override
  String get personaChatPreviewSampleMessage =>
      'Hello! This is a preview of how messages look with your display tag and active persona.';

  @override
  String get personaListTitle => 'Configured Personas';

  @override
  String get personaAddButton => 'Add Persona';

  @override
  String get personaActiveBadge => 'Active';

  @override
  String get personaMakeActive => 'Set Active';

  @override
  String get personaDeleteTitle => 'Delete Persona';

  @override
  String personaDeleteMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? This cannot be undone.';
  }

  @override
  String get personaDeleteConfirm => 'Delete';

  @override
  String get personaDeletedToast => 'Persona deleted';

  @override
  String get personaCreatedToast => 'Persona created';

  @override
  String personaCreateFailedToast(String error) {
    return 'Failed to create persona: $error';
  }

  @override
  String get personaChangeAvatar => 'Change Avatar';

  @override
  String get personaRemoveAvatar => 'Remove Avatar';

  @override
  String get personaUploadAvatar => 'Upload Avatar';

  @override
  String get personaTagsLabel => 'Persona Tags';

  @override
  String get personaTagPrefixLabel => 'Prefix';

  @override
  String get personaTagSuffixLabel => 'Suffix';

  @override
  String get personaVisibilityLabel => 'Visibility';

  @override
  String get personaVisibilityUnlisted => 'Unlisted';

  @override
  String get personaVisibilityPublic => 'Public';

  @override
  String get personaVisibilityPrivate => 'Private';

  @override
  String get personaNameRequired => 'Please enter a persona display name';

  @override
  String get personaNameTooLong =>
      'Persona display name must be 100 characters or less';

  @override
  String get personaTagPrefixTooLong =>
      'Persona tag prefix must be 32 characters or less';

  @override
  String get personaTagSuffixTooLong =>
      'Persona tag suffix must be 32 characters or less';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'The tag \'$tag\' is already in use by \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Insert timestamp';

  @override
  String get chatAttachmentSendVoiceMessage => 'Send voice message';

  @override
  String get timestampPickerTitle => 'Insert Timestamp';

  @override
  String get timestampPickerInsert => 'Insert';

  @override
  String get timestampCopied => 'Timestamp copied';

  @override
  String get timestampPickerTimeLabel => 'Time';

  @override
  String get timestampPickerDateLabel => 'DATE';

  @override
  String get timestampPickerTimeSectionLabel => 'TIME';

  @override
  String get timestampPickerTimezoneLabel => 'TIME ZONE';

  @override
  String get timestampPickerFormatPreviewLabel => 'FORMAT PREVIEW';

  @override
  String get timestampPickerNlpPlaceholder =>
      'e.g. tomorrow at 3pm, in 2 hours, now';

  @override
  String get timestampPickerSearchTimezones => 'Search time zones...';

  @override
  String get userProfileTimezoneSettingLabel => 'Time zone';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Used to show your local time on your profile.';

  @override
  String get userProfileTimezoneNone => 'None';

  @override
  String get chatReactAs => 'React as...';

  @override
  String get emojiCopy => 'Copy emoji';

  @override
  String get emojiCopyLink => 'Copy link';

  @override
  String get personaSignatureEmojisLabel => 'Signature Emojis';

  @override
  String get personaSignatureEmojisDescription =>
      'Reacting with a signature emoji will always react as this persona, regardless of active persona.';

  @override
  String get personaAddSignatureEmoji => 'Add Emoji';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'This emoji is already added as a signature emoji';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Signature emoji already in use by persona \"$name\"';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Remove signature emoji';

  @override
  String get signalBarLabel => 'Signal bar';

  @override
  String get signalBarShow => 'Show signal bar';

  @override
  String get signalBarHide => 'Hide signal bar';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Nobody has this signal on';

  @override
  String get signalBarReset => 'Reset signal for everyone';

  @override
  String signalBarTurnOff(String name) {
    return 'Turn off $name';
  }

  @override
  String instanceUrlHelperDefault(String domain) {
    return 'Use $domain for the default instance, or the exact URL of another instance.';
  }

  @override
  String get instanceResetToDefault => 'Reset to default instance';
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class ForkLocalizationsEnGb extends ForkLocalizationsEn {
  ForkLocalizationsEnGb() : super('en_GB');

  @override
  String get chatMessageChangePersona => 'Change Persona';

  @override
  String get chatAttachmentPanelVoice => 'Voice';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'Quick Switcher button';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Replace the voice message button in the message input with a Quick Switcher button for fast navigation';

  @override
  String get userSettingsCheckForUpdates => 'Check for updates';

  @override
  String get userSettingsCheckingForUpdates => 'Checking for updates…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer is up to date';

  @override
  String get userSettingsUpdateAvailableTitle => 'Update Available';

  @override
  String get userSettingsUpdateDownloadAction => 'Download & Install';

  @override
  String get userSettingsUpdateInstallAction => 'Install Update';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Downloading update ($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed => 'Failed to check or download update.';

  @override
  String get personaSelectTitle => 'Select Persona';

  @override
  String get personaSettingsHeader => 'Persona Settings';

  @override
  String get personaManageAction => 'Manage';

  @override
  String get personaSearchPlaceholder => 'Search personas, tags, pronouns...';

  @override
  String get personaModeManual => 'Manual';

  @override
  String get personaModeLast => 'Last Used';

  @override
  String get personaModeManualDescription =>
      'Always sends as selected persona until changed.';

  @override
  String get personaModeLastDescription =>
      'Auto-switches to the persona used in your last message.';

  @override
  String get personaRecentHeader => 'RECENT PERSONAS';

  @override
  String personaAllHeader(int count) {
    return 'ALL PERSONAS ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'SEARCH RESULTS ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Root Account (Default)';

  @override
  String get personaEmptyState =>
      'No personas configured yet. Create one via Manage Personas.';

  @override
  String get personaEmptySearch => 'No matching personas found.';

  @override
  String get personaEditTitle => 'Edit Persona';

  @override
  String get personaCreateTitle => 'Create Persona';

  @override
  String get personaDisplayNameLabel => 'Display Name';

  @override
  String get personaPronounsLabel => 'Pronouns';

  @override
  String get personaPronounsHint => 'e.g. they/them';

  @override
  String get personaBioHint => 'Tell others about this persona...';

  @override
  String get personaUpdatedToast => 'Persona updated';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Failed to update persona: $error';
  }

  @override
  String get personaSectionTitle => 'Personas';

  @override
  String get personaDisplayNameHint => 'Persona name';

  @override
  String personaSendingAsTag(String name) {
    return 'Sending as $name (Matched by tag)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Sending as $name (Latched)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Sending as @$username';
  }

  @override
  String get personaMainAccount => 'Main account';

  @override
  String get personaEditPersona => 'Edit persona';

  @override
  String get userSettingsNavPersonas => 'Personas';

  @override
  String get personaSettingsDescription =>
      'Configure your active persona mode, custom display tag, and manage individual personas.';

  @override
  String get personaDisplayTagSection => 'Display Tag';

  @override
  String get personaDisplayTagDescription =>
      'Display tag will appear next to all persona names in messages. If no display tag is set, your account profile picture will be shown.';

  @override
  String get personaDisplayTagLabel => 'Display Tag Text';

  @override
  String get personaDisplayTagHint => 'e.g. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Display Tag Icon';

  @override
  String get personaUploadTagIcon => 'Upload Icon';

  @override
  String get personaChangeTagIcon => 'Change Icon';

  @override
  String get personaRemoveTagIcon => 'Remove Icon';

  @override
  String get personaChatPreviewTitle => 'Chat Preview';

  @override
  String get personaChatPreviewSampleMessage =>
      'Hello! This is a preview of how messages look with your display tag and active persona.';

  @override
  String get personaListTitle => 'Configured Personas';

  @override
  String get personaAddButton => 'Add Persona';

  @override
  String get personaActiveBadge => 'Active';

  @override
  String get personaMakeActive => 'Set Active';

  @override
  String get personaDeleteTitle => 'Delete Persona';

  @override
  String personaDeleteMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? This cannot be undone.';
  }

  @override
  String get personaDeleteConfirm => 'Delete';

  @override
  String get personaDeletedToast => 'Persona deleted';

  @override
  String get personaCreatedToast => 'Persona created';

  @override
  String personaCreateFailedToast(String error) {
    return 'Failed to create persona: $error';
  }

  @override
  String get personaChangeAvatar => 'Change Avatar';

  @override
  String get personaRemoveAvatar => 'Remove Avatar';

  @override
  String get personaUploadAvatar => 'Upload Avatar';

  @override
  String get personaTagsLabel => 'Persona Tags';

  @override
  String get personaTagPrefixLabel => 'Prefix';

  @override
  String get personaTagSuffixLabel => 'Suffix';

  @override
  String get personaVisibilityLabel => 'Visibility';

  @override
  String get personaVisibilityUnlisted => 'Unlisted';

  @override
  String get personaVisibilityPublic => 'Public';

  @override
  String get personaVisibilityPrivate => 'Private';

  @override
  String get personaNameRequired => 'Please enter a persona display name';

  @override
  String get personaNameTooLong =>
      'Persona display name must be 100 characters or less';

  @override
  String get personaTagPrefixTooLong =>
      'Persona tag prefix must be 32 characters or less';

  @override
  String get personaTagSuffixTooLong =>
      'Persona tag suffix must be 32 characters or less';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'The tag \'$tag\' is already in use by \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Insert timestamp';

  @override
  String get chatAttachmentSendVoiceMessage => 'Send voice message';

  @override
  String get timestampPickerTitle => 'Insert Timestamp';

  @override
  String get timestampPickerInsert => 'Insert';

  @override
  String get timestampCopied => 'Timestamp copied';

  @override
  String get timestampPickerTimeLabel => 'Time';

  @override
  String get timestampPickerDateLabel => 'DATE';

  @override
  String get timestampPickerTimeSectionLabel => 'TIME';

  @override
  String get timestampPickerTimezoneLabel => 'TIME ZONE';

  @override
  String get timestampPickerFormatPreviewLabel => 'FORMAT PREVIEW';

  @override
  String get timestampPickerNlpPlaceholder =>
      'e.g. tomorrow at 3pm, in 2 hours, now';

  @override
  String get timestampPickerSearchTimezones => 'Search time zones...';

  @override
  String get userProfileTimezoneSettingLabel => 'Time zone';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Used to show your local time on your profile.';

  @override
  String get userProfileTimezoneNone => 'None';

  @override
  String get chatReactAs => 'React as...';

  @override
  String get emojiCopy => 'Copy emoji';

  @override
  String get emojiCopyLink => 'Copy link';

  @override
  String get personaSignatureEmojisLabel => 'Signature Emojis';

  @override
  String get personaSignatureEmojisDescription =>
      'Reacting with a signature emoji will always react as this persona, regardless of active persona.';

  @override
  String get personaAddSignatureEmoji => 'Add Emoji';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'This emoji is already added as a signature emoji';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Signature emoji already in use by persona \"$name\"';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Remove signature emoji';

  @override
  String get signalBarLabel => 'Signal bar';

  @override
  String get signalBarShow => 'Show signal bar';

  @override
  String get signalBarHide => 'Hide signal bar';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Nobody has this signal on';

  @override
  String get signalBarReset => 'Reset signal for everyone';

  @override
  String signalBarTurnOff(String name) {
    return 'Turn off $name';
  }

  @override
  String instanceUrlHelperDefault(String domain) {
    return 'Use $domain for the default instance, or the exact URL of another instance.';
  }

  @override
  String get instanceResetToDefault => 'Reset to default instance';
}

/// The translations for English, as used in the United States (`en_US`).
class ForkLocalizationsEnUs extends ForkLocalizationsEn {
  ForkLocalizationsEnUs() : super('en_US');

  @override
  String get chatMessageChangePersona => 'Change Persona';

  @override
  String get chatAttachmentPanelVoice => 'Voice';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'Quick Switcher button';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Replace the voice message button in the message input with a Quick Switcher button for fast navigation';

  @override
  String get userSettingsCheckForUpdates => 'Check for updates';

  @override
  String get userSettingsCheckingForUpdates => 'Checking for updates…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer is up to date';

  @override
  String get userSettingsUpdateAvailableTitle => 'Update Available';

  @override
  String get userSettingsUpdateDownloadAction => 'Download & Install';

  @override
  String get userSettingsUpdateInstallAction => 'Install Update';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Downloading update ($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed => 'Failed to check or download update.';

  @override
  String get personaSelectTitle => 'Select Persona';

  @override
  String get personaSettingsHeader => 'Persona Settings';

  @override
  String get personaManageAction => 'Manage';

  @override
  String get personaSearchPlaceholder => 'Search personas, tags, pronouns...';

  @override
  String get personaModeManual => 'Manual';

  @override
  String get personaModeLast => 'Last Used';

  @override
  String get personaModeManualDescription =>
      'Always sends as selected persona until changed.';

  @override
  String get personaModeLastDescription =>
      'Auto-switches to the persona used in your last message.';

  @override
  String get personaRecentHeader => 'RECENT PERSONAS';

  @override
  String personaAllHeader(int count) {
    return 'ALL PERSONAS ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'SEARCH RESULTS ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Root Account (Default)';

  @override
  String get personaEmptyState =>
      'No personas configured yet. Create one via Manage Personas.';

  @override
  String get personaEmptySearch => 'No matching personas found.';

  @override
  String get personaEditTitle => 'Edit Persona';

  @override
  String get personaCreateTitle => 'Create Persona';

  @override
  String get personaDisplayNameLabel => 'Display Name';

  @override
  String get personaPronounsLabel => 'Pronouns';

  @override
  String get personaPronounsHint => 'e.g. they/them';

  @override
  String get personaBioHint => 'Tell others about this persona...';

  @override
  String get personaUpdatedToast => 'Persona updated';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Failed to update persona: $error';
  }

  @override
  String get personaSectionTitle => 'Personas';

  @override
  String get personaDisplayNameHint => 'Persona name';

  @override
  String personaSendingAsTag(String name) {
    return 'Sending as $name (Matched by tag)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Sending as $name (Latched)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Sending as @$username';
  }

  @override
  String get personaMainAccount => 'Main account';

  @override
  String get personaEditPersona => 'Edit persona';

  @override
  String get userSettingsNavPersonas => 'Personas';

  @override
  String get personaSettingsDescription =>
      'Configure your active persona mode, custom display tag, and manage individual personas.';

  @override
  String get personaDisplayTagSection => 'Display Tag';

  @override
  String get personaDisplayTagDescription =>
      'Display tag will appear next to all persona names in messages. If no display tag is set, your account profile picture will be shown.';

  @override
  String get personaDisplayTagLabel => 'Display Tag Text';

  @override
  String get personaDisplayTagHint => 'e.g. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Display Tag Icon';

  @override
  String get personaUploadTagIcon => 'Upload Icon';

  @override
  String get personaChangeTagIcon => 'Change Icon';

  @override
  String get personaRemoveTagIcon => 'Remove Icon';

  @override
  String get personaChatPreviewTitle => 'Chat Preview';

  @override
  String get personaChatPreviewSampleMessage =>
      'Hello! This is a preview of how messages look with your display tag and active persona.';

  @override
  String get personaListTitle => 'Configured Personas';

  @override
  String get personaAddButton => 'Add Persona';

  @override
  String get personaActiveBadge => 'Active';

  @override
  String get personaMakeActive => 'Set Active';

  @override
  String get personaDeleteTitle => 'Delete Persona';

  @override
  String personaDeleteMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? This cannot be undone.';
  }

  @override
  String get personaDeleteConfirm => 'Delete';

  @override
  String get personaDeletedToast => 'Persona deleted';

  @override
  String get personaCreatedToast => 'Persona created';

  @override
  String personaCreateFailedToast(String error) {
    return 'Failed to create persona: $error';
  }

  @override
  String get personaChangeAvatar => 'Change Avatar';

  @override
  String get personaRemoveAvatar => 'Remove Avatar';

  @override
  String get personaUploadAvatar => 'Upload Avatar';

  @override
  String get personaTagsLabel => 'Persona Tags';

  @override
  String get personaTagPrefixLabel => 'Prefix';

  @override
  String get personaTagSuffixLabel => 'Suffix';

  @override
  String get personaVisibilityLabel => 'Visibility';

  @override
  String get personaVisibilityUnlisted => 'Unlisted';

  @override
  String get personaVisibilityPublic => 'Public';

  @override
  String get personaVisibilityPrivate => 'Private';

  @override
  String get personaNameRequired => 'Please enter a persona display name';

  @override
  String get personaNameTooLong =>
      'Persona display name must be 100 characters or less';

  @override
  String get personaTagPrefixTooLong =>
      'Persona tag prefix must be 32 characters or less';

  @override
  String get personaTagSuffixTooLong =>
      'Persona tag suffix must be 32 characters or less';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'The tag \'$tag\' is already in use by \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Insert timestamp';

  @override
  String get chatAttachmentSendVoiceMessage => 'Send voice message';

  @override
  String get timestampPickerTitle => 'Insert Timestamp';

  @override
  String get timestampPickerInsert => 'Insert';

  @override
  String get timestampCopied => 'Timestamp copied';

  @override
  String get timestampPickerTimeLabel => 'Time';

  @override
  String get timestampPickerDateLabel => 'DATE';

  @override
  String get timestampPickerTimeSectionLabel => 'TIME';

  @override
  String get timestampPickerTimezoneLabel => 'TIME ZONE';

  @override
  String get timestampPickerFormatPreviewLabel => 'FORMAT PREVIEW';

  @override
  String get timestampPickerNlpPlaceholder =>
      'e.g. tomorrow at 3pm, in 2 hours, now';

  @override
  String get timestampPickerSearchTimezones => 'Search time zones...';

  @override
  String get userProfileTimezoneSettingLabel => 'Time zone';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Used to show your local time on your profile.';

  @override
  String get userProfileTimezoneNone => 'None';

  @override
  String get chatReactAs => 'React as...';

  @override
  String get emojiCopy => 'Copy emoji';

  @override
  String get emojiCopyLink => 'Copy link';

  @override
  String get personaSignatureEmojisLabel => 'Signature Emojis';

  @override
  String get personaSignatureEmojisDescription =>
      'Reacting with a signature emoji will always react as this persona, regardless of active persona.';

  @override
  String get personaAddSignatureEmoji => 'Add Emoji';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'This emoji is already added as a signature emoji';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Signature emoji already in use by persona \"$name\"';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Remove signature emoji';

  @override
  String get signalBarLabel => 'Signal bar';

  @override
  String get signalBarShow => 'Show signal bar';

  @override
  String get signalBarHide => 'Hide signal bar';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Nobody has this signal on';

  @override
  String get signalBarReset => 'Reset signal for everyone';

  @override
  String signalBarTurnOff(String name) {
    return 'Turn off $name';
  }

  @override
  String instanceUrlHelperDefault(String domain) {
    return 'Use $domain for the default instance, or the exact URL of another instance.';
  }

  @override
  String get instanceResetToDefault => 'Reset to default instance';
}
