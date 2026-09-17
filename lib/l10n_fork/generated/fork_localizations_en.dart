// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ForkLocalizationsEn extends ForkLocalizations {
  ForkLocalizationsEn([String locale = 'en']) : super(locale);

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
      'Sends as root account unless proxy tags are typed.';

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
  String get personaDisplayNameLabel => 'Display Name';

  @override
  String get personaSystemTagLabel => 'System Tag / Badge';

  @override
  String get personaPronounsLabel => 'Pronouns';

  @override
  String get personaPronounsHint => 'e.g. they/them';

  @override
  String get personaBioLabel => 'Bio / About Me';

  @override
  String get personaBioHint => 'Tell others about this persona...';

  @override
  String get personaSaveChanges => 'Save Changes';

  @override
  String get personaUpdatedToast => 'Persona updated';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Failed to update persona: $error';
  }

  @override
  String get personaDisplayNameHint => 'Persona name';

  @override
  String get personaSystemTagHint => 'e.g. SYSTEM NAME';

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
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class ForkLocalizationsEnGb extends ForkLocalizationsEn {
  ForkLocalizationsEnGb() : super('en_GB');
}

/// The translations for English, as used in the United States (`en_US`).
class ForkLocalizationsEnUs extends ForkLocalizationsEn {
  ForkLocalizationsEnUs() : super('en_US');
}
