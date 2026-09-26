// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class ForkLocalizationsNl extends ForkLocalizations {
  ForkLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Persona wijzigen';

  @override
  String get chatAttachmentPanelVoice => 'Spraak';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'Snelschakelaar-knop';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Vervang de spraakbericht-knop in het invoerveld door een snelschakelaar voor snelle navigatie';

  @override
  String get userSettingsCheckForUpdates => 'Controleren op updates';

  @override
  String get userSettingsCheckingForUpdates => 'Controleren op updates…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer is up-to-date';

  @override
  String get userSettingsUpdateAvailableTitle => 'Update beschikbaar';

  @override
  String get userSettingsUpdateDownloadAction => 'Downloaden & installeren';

  @override
  String get userSettingsUpdateInstallAction => 'Update installeren';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Update downloaden ($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Kan niet controleren op of downloaden van update.';

  @override
  String get personaSelectTitle => 'Persona kiezen';

  @override
  String get personaSettingsHeader => 'Persona-instellingen';

  @override
  String get personaManageAction => 'Beheren';

  @override
  String get personaSearchPlaceholder =>
      'Zoek persona\'s, tags, voornaamwoorden...';

  @override
  String get personaModeManual => 'Handmatig';

  @override
  String get personaModeLast => 'Laatst gebruikt';

  @override
  String get personaModeManualDescription =>
      'Verzendt altijd als geselecteerde persona totdat dit wordt gewijzigd.';

  @override
  String get personaModeLastDescription =>
      'Schakelt automatisch over naar de persona die in je laatste bericht is gebruikt.';

  @override
  String get personaRecentHeader => 'RECENTE PERSONA\'S';

  @override
  String personaAllHeader(int count) {
    return 'ALLE PERSONA\'S ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'ZOEKRESULTATEN ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Hoofdaccount (Standaard)';

  @override
  String get personaEmptyState =>
      'Nog geen persona\'s geconfigureerd. Maak er een aan via Persona\'s beheren.';

  @override
  String get personaEmptySearch => 'Geen overeenkomende persona\'s gevonden.';

  @override
  String get personaEditTitle => 'Persona bewerken';

  @override
  String get personaCreateTitle => 'Persona aanmaken';

  @override
  String get personaDisplayNameLabel => 'Weergavenaam';

  @override
  String get personaPronounsLabel => 'Voornaamwoorden';

  @override
  String get personaPronounsHint => 'bijv. die/hen';

  @override
  String get personaBioHint => 'Vertel anderen over deze persona...';

  @override
  String get personaUpdatedToast => 'Persona bijgewerkt';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Kon persona niet bijwerken: $error';
  }

  @override
  String get personaSectionTitle => 'Persona\'s';

  @override
  String get personaDisplayNameHint => 'Personanaam';

  @override
  String personaSendingAsTag(String name) {
    return 'Verzenden als $name (Gekoppeld via tag)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Verzenden als $name (Vastgezet)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Verzenden als @$username';
  }

  @override
  String get personaMainAccount => 'Hoofdaccount';

  @override
  String get personaEditPersona => 'Persona bewerken';

  @override
  String get userSettingsNavPersonas => 'Persona\'s';

  @override
  String get personaSettingsDescription =>
      'Configureer je actieve persona-modus, aangepaste weergavetag en beheer individuele persona\'s.';

  @override
  String get personaDisplayTagSection => 'Weergavetag';

  @override
  String get personaDisplayTagDescription =>
      'De weergavetag verschijnt naast alle personanamen in berichten. Als er geen weergavetag is ingesteld, wordt de profielfoto van je account weergegeven.';

  @override
  String get personaDisplayTagLabel => 'Tekst van weergavetag';

  @override
  String get personaDisplayTagHint => 'bijv. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Pictogram van weergavetag';

  @override
  String get personaUploadTagIcon => 'Pictogram uploaden';

  @override
  String get personaChangeTagIcon => 'Pictogram wijzigen';

  @override
  String get personaRemoveTagIcon => 'Pictogram verwijderen';

  @override
  String get personaChatPreviewTitle => 'Chatvoorbeeld';

  @override
  String get personaChatPreviewSampleMessage =>
      'Hallo! Dit is een voorbeeld van hoe berichten eruitzien met je weergavetag en actieve persona.';

  @override
  String get personaListTitle => 'Geconfigureerde persona\'s';

  @override
  String get personaAddButton => 'Persona toevoegen';

  @override
  String get personaActiveBadge => 'Actief';

  @override
  String get personaMakeActive => 'Als actief instellen';

  @override
  String get personaDeleteTitle => 'Persona verwijderen';

  @override
  String personaDeleteMessage(String name) {
    return 'Weet je zeker dat je \"$name\" wilt verwijderen? Dit kan niet ongedaan worden gemaakt.';
  }

  @override
  String get personaDeleteConfirm => 'Verwijderen';

  @override
  String get personaDeletedToast => 'Persona verwijderd';

  @override
  String get personaCreatedToast => 'Persona aangemaakt';

  @override
  String personaCreateFailedToast(String error) {
    return 'Kon persona niet aanmaken: $error';
  }

  @override
  String get personaChangeAvatar => 'Avatar wijzigen';

  @override
  String get personaRemoveAvatar => 'Avatar verwijderen';

  @override
  String get personaUploadAvatar => 'Avatar uploaden';

  @override
  String get personaTagsLabel => 'Persona-tags';

  @override
  String get personaTagPrefixLabel => 'Voorvoegsel';

  @override
  String get personaTagSuffixLabel => 'Achtervoegsel';

  @override
  String get personaVisibilityLabel => 'Zichtbaarheid';

  @override
  String get personaVisibilityUnlisted => 'Niet vermeld';

  @override
  String get personaVisibilityPublic => 'Openbaar';

  @override
  String get personaVisibilityPrivate => 'Privé';

  @override
  String get personaNameRequired => 'Voer een weergavenaam voor de persona in';

  @override
  String get personaNameTooLong =>
      'Weergavenaam van persona mag maximaal 100 tekens bevatten';

  @override
  String get personaTagPrefixTooLong =>
      'Persona-tagvoorvoegsel mag maximaal 32 tekens bevatten';

  @override
  String get personaTagSuffixTooLong =>
      'Persona-tagachtervoegsel mag maximaal 32 tekens bevatten';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'De tag \'$tag\' is al in gebruik door \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Tijdstempel invoegen';

  @override
  String get timestampPickerTitle => 'Tijdstempel invoegen';

  @override
  String get timestampPickerInsert => 'Invoegen';

  @override
  String get timestampCopied => 'Tijdstempel gekopieerd';

  @override
  String get timestampPickerTimeLabel => 'Tijd';

  @override
  String get timestampPickerDateLabel => 'DATUM';

  @override
  String get timestampPickerTimeSectionLabel => 'TIJD';

  @override
  String get timestampPickerTimezoneLabel => 'TIJDZONE';

  @override
  String get timestampPickerFormatPreviewLabel => 'VOORBEELD VAN FORMAT';

  @override
  String get timestampPickerNlpPlaceholder =>
      'bijv. morgen om 15:00, over 2 uur, nu';

  @override
  String get timestampPickerSearchTimezones => 'Tijdzones zoeken...';

  @override
  String get userProfileTimezoneSettingLabel => 'Tijdzone';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Wordt gebruikt om uw lokale tijd op uw profiel te tonen.';

  @override
  String get userProfileTimezoneNone => 'Geen';
}
