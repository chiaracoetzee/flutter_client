// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class ForkLocalizationsNb extends ForkLocalizations {
  ForkLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Endre persona';

  @override
  String get chatAttachmentPanelVoice => 'Tale';

  @override
  String get advancedSettingQuickSwitcherButtonLabel =>
      'Knapp for hurtigbytter';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Erstatt talemeldingsknappen i meldingsfeltet med en hurtigbytter for enklere navigering';

  @override
  String get userSettingsCheckForUpdates => 'Se etter oppdateringer';

  @override
  String get userSettingsCheckingForUpdates => 'Ser etter oppdateringer…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer er oppdatert';

  @override
  String get userSettingsUpdateAvailableTitle => 'Oppdatering tilgjengelig';

  @override
  String get userSettingsUpdateDownloadAction => 'Last ned og installer';

  @override
  String get userSettingsUpdateInstallAction => 'Installer oppdatering';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Laster ned oppdatering ($percent %)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Kunne ikke søke etter eller laste ned oppdatering.';

  @override
  String get personaSelectTitle => 'Velg persona';

  @override
  String get personaSettingsHeader => 'Personainnstillinger';

  @override
  String get personaManageAction => 'Administrer';

  @override
  String get personaSearchPlaceholder =>
      'Søk etter personaer, tagger, pronomen...';

  @override
  String get personaModeManual => 'Manuell';

  @override
  String get personaModeLast => 'Sist brukt';

  @override
  String get personaModeManualDescription =>
      'Sender alltid som valgt persona til det endres.';

  @override
  String get personaModeLastDescription =>
      'Bytter automatisk til personaen som ble brukt i den siste meldingen din.';

  @override
  String get personaRecentHeader => 'NYLIGE PERSONAER';

  @override
  String personaAllHeader(int count) {
    return 'ALLE PERSONAER ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'SØKERESULTATER ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Hovedkonto (standard)';

  @override
  String get personaEmptyState =>
      'Ingen personaer er konfigurert ennå. Opprett en via Administrer personaer.';

  @override
  String get personaEmptySearch => 'Ingen samsvarende personaer funnet.';

  @override
  String get personaEditTitle => 'Rediger persona';

  @override
  String get personaCreateTitle => 'Opprett persona';

  @override
  String get personaDisplayNameLabel => 'Visningsnavn';

  @override
  String get personaPronounsLabel => 'Pronomen';

  @override
  String get personaPronounsHint => 'f.eks. de/dem';

  @override
  String get personaBioHint => 'Fortell andre om denne personaen...';

  @override
  String get personaUpdatedToast => 'Persona oppdatert';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Kunne ikke oppdatere persona: $error';
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
      'Konfigurer din aktive personamodus, tilpassede visningstag og administrer individuelle personaer.';

  @override
  String get personaDisplayTagSection => 'Visningstag';

  @override
  String get personaDisplayTagDescription =>
      'Visningstag vil vises ved siden av alle personanavn i meldinger. Hvis ingen visningstag er angitt, vises kontoprofilbildet ditt.';

  @override
  String get personaDisplayTagLabel => 'Visningstag-tekst';

  @override
  String get personaDisplayTagHint => 'f.eks. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Ikon for visningstag';

  @override
  String get personaUploadTagIcon => 'Last opp ikon';

  @override
  String get personaChangeTagIcon => 'Endre ikon';

  @override
  String get personaRemoveTagIcon => 'Fjern ikon';

  @override
  String get personaChatPreviewTitle => 'Forhåndsvisning av chat';

  @override
  String get personaChatPreviewSampleMessage =>
      'Hei! Dette er en forhåndsvisning av hvordan meldinger ser ut med din visningstag og aktive persona.';

  @override
  String get personaListTitle => 'Konfigurerte personaer';

  @override
  String get personaAddButton => 'Legg til persona';

  @override
  String get personaActiveBadge => 'Aktiv';

  @override
  String get personaMakeActive => 'Sett som aktiv';

  @override
  String get personaDeleteTitle => 'Slett persona';

  @override
  String personaDeleteMessage(String name) {
    return 'Er du sikker på at du vil slette «$name»? Dette kan ikke angres.';
  }

  @override
  String get personaDeleteConfirm => 'Slett';

  @override
  String get personaDeletedToast => 'Persona slettet';

  @override
  String get personaCreatedToast => 'Persona opprettet';

  @override
  String personaCreateFailedToast(String error) {
    return 'Kunne ikke opprette persona: $error';
  }

  @override
  String get personaChangeAvatar => 'Endre avatar';

  @override
  String get personaRemoveAvatar => 'Fjern avatar';

  @override
  String get personaUploadAvatar => 'Last opp avatar';

  @override
  String get personaTagsLabel => 'Personatagger';

  @override
  String get personaTagPrefixLabel => 'Prefiks';

  @override
  String get personaTagSuffixLabel => 'Suffiks';

  @override
  String get personaVisibilityLabel => 'Synlighet';

  @override
  String get personaVisibilityUnlisted => 'Uoppført';

  @override
  String get personaVisibilityPublic => 'Offentlig';

  @override
  String get personaVisibilityPrivate => 'Privat';

  @override
  String get personaNameRequired =>
      'Vennligst oppgi et visningsnavn for personaen';

  @override
  String get personaNameTooLong =>
      'Visningsnavnet for personaen kan maksimalt være 100 tegn';

  @override
  String get personaTagPrefixTooLong =>
      'Persona-taggprefikset kan maksimalt være 32 tegn';

  @override
  String get personaTagSuffixTooLong =>
      'Persona-taggsuffikset kan maksimalt være 32 tegn';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Taggen \'$tag\' er allerede i bruk av \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Sett inn tidsstempel';

  @override
  String get timestampPickerTitle => 'Sett inn tidsstempel';

  @override
  String get timestampPickerInsert => 'Sett inn';

  @override
  String get timestampCopied => 'Tidsstempel kopiert';

  @override
  String get timestampPickerTimeLabel => 'Tid';

  @override
  String get timestampPickerDateLabel => 'DATO';

  @override
  String get timestampPickerTimeSectionLabel => 'TID';

  @override
  String get timestampPickerTimezoneLabel => 'TIDSSONE';

  @override
  String get timestampPickerFormatPreviewLabel => 'FORHÅNDSVISNING AV FORMAT';

  @override
  String get timestampPickerNlpPlaceholder =>
      'f.eks. i morgen kl 15, om 2 timer, nå';

  @override
  String get timestampPickerSearchTimezones => 'Søk etter tidssoner...';

  @override
  String get userProfileTimezoneSettingLabel => 'Tidssone';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Brukes til å vise din lokale tid på profilen din.';

  @override
  String get userProfileTimezoneNone => 'Ingen';

  @override
  String get chatReactAs => 'Reager som...';

  @override
  String get emojiCopy => 'Kopier emoji';

  @override
  String get emojiCopyLink => 'Kopier lenke';

  @override
  String get personaSignatureEmojisLabel => 'Signaturemojier';

  @override
  String get personaSignatureEmojisDescription =>
      'Reaksjon med en signaturemoji vil alltid reagere som denne personaen, uavhengig av aktiv persona.';

  @override
  String get personaAddSignatureEmoji => 'Legg til emoji';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Denne emojien er allerede lagt til som en signaturemoji';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Signaturemojien brukes allerede av personaen «$name»';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Fjern signaturemoji';

  @override
  String get signalBarLabel => 'Signallinje';

  @override
  String get signalBarShow => 'Vis signallinje';

  @override
  String get signalBarHide => 'Skjul signallinje';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Ingen har dette signalet på';

  @override
  String get signalBarReset => 'Tilbakestill signalet for alle';

  @override
  String signalBarTurnOff(String name) {
    return 'Slå av $name';
  }
}
