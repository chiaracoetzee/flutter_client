// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class ForkLocalizationsDa extends ForkLocalizations {
  ForkLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Skift persona';

  @override
  String get chatAttachmentPanelVoice => 'Stemme';

  @override
  String get advancedSettingQuickSwitcherButtonLabel =>
      'Knap til hurtigskifter';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Erstat knappen til stemmemeddelelser i beskedfeltet med en hurtigskifter for nemmere navigation';

  @override
  String get userSettingsCheckForUpdates => 'Søg efter opdateringer';

  @override
  String get userSettingsCheckingForUpdates => 'Søger efter opdateringer…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer er opdateret';

  @override
  String get userSettingsUpdateAvailableTitle => 'Opdatering tilgængelig';

  @override
  String get userSettingsUpdateDownloadAction => 'Download og installer';

  @override
  String get userSettingsUpdateInstallAction => 'Installer opdatering';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Downloader opdatering ($percent %)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Kunne ikke søge efter eller downloade opdatering.';

  @override
  String get personaSelectTitle => 'Vælg persona';

  @override
  String get personaSettingsHeader => 'Personaindstillinger';

  @override
  String get personaManageAction => 'Administrer';

  @override
  String get personaSearchPlaceholder =>
      'Søg efter personaer, tags, pronominer...';

  @override
  String get personaModeOff => 'Fra';

  @override
  String get personaModeManual => 'Manuel';

  @override
  String get personaModeLast => 'Senest brugt';

  @override
  String get personaModeOffDescription =>
      'Sender som hovedkonto, medmindre der skrives persona-tags.';

  @override
  String get personaModeManualDescription =>
      'Sender altid som den valgte persona, indtil det ændres.';

  @override
  String get personaModeLastDescription =>
      'Skifter automatisk til den persona, der blev brugt i din sidste besked.';

  @override
  String get personaRecentHeader => 'SENASTE PERSONAER';

  @override
  String personaAllHeader(int count) {
    return 'ALLE PERSONAER ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'SØGERESULTATER ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Hovedkonto (standard)';

  @override
  String get personaEmptyState =>
      'Ingen personaer konfigureret endnu. Opret en via Administrer personaer.';

  @override
  String get personaEmptySearch => 'Fandt ingen matchende personaer.';

  @override
  String get personaEditTitle => 'Rediger persona';

  @override
  String get personaCreateTitle => 'Opret persona';

  @override
  String get personaDisplayNameLabel => 'Visningsnavn';

  @override
  String get personaPronounsLabel => 'Pronominer';

  @override
  String get personaPronounsHint => 'f.eks. de/dem';

  @override
  String get personaBioHint => 'Fortæl andre om denne persona...';

  @override
  String get personaUpdatedToast => 'Persona opdateret';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Kunne ikke opdatere persona: $error';
  }

  @override
  String get personaSectionTitle => 'Personaer';

  @override
  String get personaDisplayNameHint => 'Personanavn';

  @override
  String personaSendingAsTag(String name) {
    return 'Sender som $name (matchet via tag)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Sender som $name (låst)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Sender som @$username';
  }

  @override
  String get personaMainAccount => 'Hovedkonto';

  @override
  String get personaEditPersona => 'Rediger persona';

  @override
  String get userSettingsNavPersonas => 'Personaer';

  @override
  String get personaSettingsDescription =>
      'Konfigurer din aktive persona-tilstand, dit brugerdefinerede visningstag, og administrer individuelle personaer.';

  @override
  String get personaDisplayTagSection => 'Visningstag';

  @override
  String get personaDisplayTagDescription =>
      'Visningstagget vises ved siden af alle personanavne i beskeder. Hvis der ikke er angivet et visningstag, vises din kontos profilbillede.';

  @override
  String get personaDisplayTagLabel => 'Visningstag-tekst';

  @override
  String get personaDisplayTagHint => 'f.eks. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Ikon for visningstag';

  @override
  String get personaUploadTagIcon => 'Upload ikon';

  @override
  String get personaChangeTagIcon => 'Skift ikon';

  @override
  String get personaRemoveTagIcon => 'Fjern ikon';

  @override
  String get personaChatPreviewTitle => 'Forhåndsvisning af chat';

  @override
  String get personaChatPreviewSampleMessage =>
      'Hej! Dette er en forhåndsvisning af, hvordan beskeder ser ud med dit visningstag og din aktive persona.';

  @override
  String get personaListTitle => 'Konfigurerede personaer';

  @override
  String get personaAddButton => 'Tilføj persona';

  @override
  String get personaActiveBadge => 'Aktiv';

  @override
  String get personaMakeActive => 'Gør aktiv';

  @override
  String get personaDeleteTitle => 'Slet persona';

  @override
  String personaDeleteMessage(String name) {
    return 'Er du sikker på, at du vil slette \"$name\"? Dette kan ikke fortrydes.';
  }

  @override
  String get personaDeleteConfirm => 'Slet';

  @override
  String get personaDeletedToast => 'Persona slettet';

  @override
  String get personaCreatedToast => 'Persona oprettet';

  @override
  String personaCreateFailedToast(String error) {
    return 'Kunne ikke oprette persona: $error';
  }

  @override
  String get personaChangeAvatar => 'Skift avatar';

  @override
  String get personaRemoveAvatar => 'Fjern avatar';

  @override
  String get personaUploadAvatar => 'Upload avatar';

  @override
  String get personaTagsLabel => 'Persona-tags';

  @override
  String get personaTagPrefixLabel => 'Præfiks';

  @override
  String get personaTagSuffixLabel => 'Suffiks';

  @override
  String get personaVisibilityLabel => 'Synlighed';

  @override
  String get personaVisibilityUnlisted => 'Skjult';

  @override
  String get personaVisibilityPublic => 'Offentlig';

  @override
  String get personaVisibilityPrivate => 'Privat';

  @override
  String get personaNameRequired =>
      'Indtast venligst et visningsnavn for personaen';

  @override
  String get personaNameTooLong =>
      'Personaens visningsnavn må højst være på 100 tegn';

  @override
  String get personaTagPrefixTooLong =>
      'Persona-tagpræfiks må højst være på 32 tegn';

  @override
  String get personaTagSuffixTooLong =>
      'Persona-tagsuffiks må højst være på 32 tegn';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Tagget \'$tag\' er allerede i brug af \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Indsæt tidsstempel';

  @override
  String get timestampPickerTitle => 'Indsæt tidsstempel';

  @override
  String get timestampPickerInsert => 'Indsæt';

  @override
  String get timestampCopied => 'Tidsstempel kopieret';

  @override
  String get timestampPickerTimeLabel => 'Tid';

  @override
  String get timestampPickerDateLabel => 'DATO';

  @override
  String get timestampPickerTimeSectionLabel => 'TIDSPUNKT';

  @override
  String get timestampPickerTimezoneLabel => 'TIDSZONE';

  @override
  String get timestampPickerFormatPreviewLabel => 'FORMATFORHÅNDSVISNING';

  @override
  String get timestampPickerNlpPlaceholder =>
      'f.eks. i morgen kl. 15, om 2 timer, nu';

  @override
  String get timestampPickerSearchTimezones => 'Søg efter tidszoner...';

  @override
  String get userProfileTimezoneSettingLabel => 'Tidszone';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Bruges til at vise din lokale tid på din profil.';

  @override
  String get userProfileTimezoneNone => 'Ingen';
}
