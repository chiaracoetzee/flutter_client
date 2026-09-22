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
  String get advancedSettingQuickSwitcherButtonLabel => 'Quick Switcher button';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Replace the voice message button in the message input with a Quick Switcher button for fast navigation';

  @override
  String get personaSelectTitle => 'Select Persona';

  @override
  String get personaSettingsHeader => 'Persona Settings';

  @override
  String get personaManageAction => 'Manage';

  @override
  String get personaSearchPlaceholder => 'Search personas, tags, pronouns...';

  @override
  String get personaModeOff => 'Off';

  @override
  String get personaModeManual => 'Manual';

  @override
  String get personaModeLast => 'Last Used';

  @override
  String get personaModeOffDescription =>
      'Sends as root account unless persona tags are typed.';

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
  String get personaBioLabel => 'Bio / About Me';

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
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class ForkLocalizationsEnGb extends ForkLocalizationsEn {
  ForkLocalizationsEnGb() : super('en_GB');

  @override
  String get chatMessageChangePersona => 'Change Persona';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'Quick Switcher button';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Replace the voice message button in the message input with a Quick Switcher button for fast navigation';

  @override
  String get personaSelectTitle => 'Select Persona';

  @override
  String get personaSettingsHeader => 'Persona Settings';

  @override
  String get personaManageAction => 'Manage';

  @override
  String get personaSearchPlaceholder => 'Search personas, tags, pronouns...';

  @override
  String get personaModeOff => 'Off';

  @override
  String get personaModeManual => 'Manual';

  @override
  String get personaModeLast => 'Last Used';

  @override
  String get personaModeOffDescription =>
      'Sends as root account unless persona tags are typed.';

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
  String get personaBioLabel => 'Bio / About Me';

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
}

/// The translations for English, as used in the United States (`en_US`).
class ForkLocalizationsEnUs extends ForkLocalizationsEn {
  ForkLocalizationsEnUs() : super('en_US');

  @override
  String get chatMessageChangePersona => 'Change Persona';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'Quick Switcher button';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Replace the voice message button in the message input with a Quick Switcher button for fast navigation';

  @override
  String get personaSelectTitle => 'Select Persona';

  @override
  String get personaSettingsHeader => 'Persona Settings';

  @override
  String get personaManageAction => 'Manage';

  @override
  String get personaSearchPlaceholder => 'Search personas, tags, pronouns...';

  @override
  String get personaModeOff => 'Off';

  @override
  String get personaModeManual => 'Manual';

  @override
  String get personaModeLast => 'Last Used';

  @override
  String get personaModeOffDescription =>
      'Sends as root account unless persona tags are typed.';

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
  String get personaBioLabel => 'Bio / About Me';

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
}
