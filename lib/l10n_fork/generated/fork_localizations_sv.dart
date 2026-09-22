// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class ForkLocalizationsSv extends ForkLocalizations {
  ForkLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Byt persona';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'Snabbväxlarknapp';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Ersätt knappen för röstmeddelande i inmatningsfältet med en snabbväxlare för smidig navigering';

  @override
  String get personaSelectTitle => 'Välj persona';

  @override
  String get personaSettingsHeader => 'Personainställningar';

  @override
  String get personaManageAction => 'Hantera';

  @override
  String get personaSearchPlaceholder => 'Sök personas, taggar, pronomen...';

  @override
  String get personaModeOff => 'Av';

  @override
  String get personaModeManual => 'Manuellt';

  @override
  String get personaModeLast => 'Senast använd';

  @override
  String get personaModeOffDescription =>
      'Skickar som huvudkonto såvida inte personataggar skrivs.';

  @override
  String get personaModeManualDescription =>
      'Skickar alltid som vald persona tills det ändras.';

  @override
  String get personaModeLastDescription =>
      'Växlar automatiskt till den persona som användes i ditt senaste meddelande.';

  @override
  String get personaRecentHeader => 'SENASTE PERSONAS';

  @override
  String personaAllHeader(int count) {
    return 'ALLA PERSONAS ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'SÖKRESULTAT ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Huvudkonto (standard)';

  @override
  String get personaEmptyState =>
      'Inga personas har konfigurerats än. Skapa en via Hantera personas.';

  @override
  String get personaEmptySearch => 'Hittade inga matchande personas.';

  @override
  String get personaEditTitle => 'Redigera persona';

  @override
  String get personaCreateTitle => 'Skapa persona';

  @override
  String get personaDisplayNameLabel => 'Visningsnamn';

  @override
  String get personaPronounsLabel => 'Pronomen';

  @override
  String get personaPronounsHint => 't.ex. hen/henom';

  @override
  String get personaBioLabel => 'Presentation / Om mig';

  @override
  String get personaBioHint => 'Berätta för andra om denna persona...';

  @override
  String get personaUpdatedToast => 'Persona uppdaterad';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Kunde inte uppdatera persona: $error';
  }

  @override
  String get personaSectionTitle => 'Personas';

  @override
  String get personaDisplayNameHint => 'Personanamn';

  @override
  String personaSendingAsTag(String name) {
    return 'Skickar som $name (matchad av tagg)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Skickar som $name (låst)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Skickar som @$username';
  }

  @override
  String get personaMainAccount => 'Huvudkonto';

  @override
  String get personaEditPersona => 'Redigera persona';

  @override
  String get userSettingsNavPersonas => 'Personas';

  @override
  String get personaSettingsDescription =>
      'Konfigurera ditt aktiva persona-läge, anpassade visningstagg och hantera enskilda personas.';

  @override
  String get personaDisplayTagSection => 'Visningstagg';

  @override
  String get personaDisplayTagDescription =>
      'Visningstaggen visas bredvid alla personanamn i meddelanden. Om ingen visningstagg anges, visas din kontoprofilbild.';

  @override
  String get personaDisplayTagLabel => 'Visningstaggtext';

  @override
  String get personaDisplayTagHint => 't.ex. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Ikon för visningstagg';

  @override
  String get personaUploadTagIcon => 'Ladda upp ikon';

  @override
  String get personaChangeTagIcon => 'Ändra ikon';

  @override
  String get personaRemoveTagIcon => 'Ta bort ikon';

  @override
  String get personaChatPreviewTitle => 'Förhandsvisning av chatt';

  @override
  String get personaChatPreviewSampleMessage =>
      'Hej! Detta är en förhandsvisning av hur meddelanden ser ut med din visningstagg och aktiva persona.';

  @override
  String get personaListTitle => 'Konfigurerade personas';

  @override
  String get personaAddButton => 'Lägg till persona';

  @override
  String get personaActiveBadge => 'Aktiv';

  @override
  String get personaMakeActive => 'Sätt som aktiv';

  @override
  String get personaDeleteTitle => 'Ta bort persona';

  @override
  String personaDeleteMessage(String name) {
    return 'Är du säker på att du vill ta bort \"$name\"? Detta kan inte ångras.';
  }

  @override
  String get personaDeleteConfirm => 'Ta bort';

  @override
  String get personaDeletedToast => 'Persona borttagen';

  @override
  String get personaCreatedToast => 'Persona skapad';

  @override
  String personaCreateFailedToast(String error) {
    return 'Kunde inte skapa persona: $error';
  }

  @override
  String get personaChangeAvatar => 'Ändra avatar';

  @override
  String get personaRemoveAvatar => 'Ta bort avatar';

  @override
  String get personaUploadAvatar => 'Ladda upp avatar';

  @override
  String get personaTagsLabel => 'Personataggar';

  @override
  String get personaTagPrefixLabel => 'Prefix';

  @override
  String get personaTagSuffixLabel => 'Suffix';

  @override
  String get personaVisibilityLabel => 'Synlighet';

  @override
  String get personaVisibilityUnlisted => 'Olistad';

  @override
  String get personaVisibilityPublic => 'Offentlig';

  @override
  String get personaVisibilityPrivate => 'Privat';

  @override
  String get personaNameRequired => 'Ange ett visningsnamn för personan';

  @override
  String get personaNameTooLong =>
      'Personans visningsnamn får vara högst 100 tecken';

  @override
  String get personaTagPrefixTooLong =>
      'Personataggens prefix får vara högst 32 tecken';

  @override
  String get personaTagSuffixTooLong =>
      'Personataggens suffix får vara högst 32 tecken';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Taggen \'$tag\' används redan av \'$name\'.';
  }
}
