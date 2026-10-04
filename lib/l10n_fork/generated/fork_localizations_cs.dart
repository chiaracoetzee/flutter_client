// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class ForkLocalizationsCs extends ForkLocalizations {
  ForkLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Změnit personu';

  @override
  String get chatAttachmentPanelVoice => 'Hlas';

  @override
  String get advancedSettingQuickSwitcherButtonLabel =>
      'Tlačítko rychlého přepínače';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Nahradit tlačítko hlasové zprávy v poli pro zadávání tlačítkem rychlého přepínače pro svižnou navigaci';

  @override
  String get userSettingsCheckForUpdates => 'Zkontrolovat aktualizace';

  @override
  String get userSettingsCheckingForUpdates => 'Kontrola aktualizací…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer je aktuální';

  @override
  String get userSettingsUpdateAvailableTitle => 'Je k dispozici aktualizace';

  @override
  String get userSettingsUpdateDownloadAction => 'Stáhnout a instalovat';

  @override
  String get userSettingsUpdateInstallAction => 'Instalovat aktualizaci';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Stahování aktualizace ($percent %)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Kontrola nebo stažení aktualizace se nezdařilo.';

  @override
  String get personaSelectTitle => 'Vyberte personu';

  @override
  String get personaSettingsHeader => 'Nastavení person';

  @override
  String get personaManageAction => 'Spravovat';

  @override
  String get personaSearchPlaceholder => 'Hledat persony, značky, zájmena...';

  @override
  String get personaModeManual => 'Ručně';

  @override
  String get personaModeLast => 'Naposledy použito';

  @override
  String get personaModeManualDescription =>
      'Vždy odesílá jako vybraná persona až do změny.';

  @override
  String get personaModeLastDescription =>
      'Automaticky přepne na personu použitou v poslední zprávě.';

  @override
  String get personaRecentHeader => 'NEDÁVNÉ PERSONY';

  @override
  String personaAllHeader(int count) {
    return 'VŠECHNY PERSONY ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'VÝSLEDKY VYHLEDÁVÁNÍ ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Hlavní účet (Výchozí)';

  @override
  String get personaEmptyState =>
      'Zatím nejsou nastaveny žádné persony. Vytvořte si ji v nabídce „Spravovat persony“.';

  @override
  String get personaEmptySearch =>
      'Nebyly nalezeny žádné odpovídající persony.';

  @override
  String get personaEditTitle => 'Upravit personu';

  @override
  String get personaCreateTitle => 'Vytvořit personu';

  @override
  String get personaDisplayNameLabel => 'Zobrazované jméno';

  @override
  String get personaPronounsLabel => 'Zájmena';

  @override
  String get personaPronounsHint => 'např. oni/jejich';

  @override
  String get personaBioHint => 'Řekněte ostatním něco o této personě...';

  @override
  String get personaUpdatedToast => 'Persona aktualizována';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Nepodařilo se aktualizovat personu: $error';
  }

  @override
  String get personaSectionTitle => 'Persony';

  @override
  String get personaDisplayNameHint => 'Jméno persony';

  @override
  String personaSendingAsTag(String name) {
    return 'Odesílá se jako $name (Přiřazeno podle značky)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Odesílá se jako $name (Uzamčeno)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Odesílá se jako @$username';
  }

  @override
  String get personaMainAccount => 'Hlavní účet';

  @override
  String get personaEditPersona => 'Upravit personu';

  @override
  String get userSettingsNavPersonas => 'Persony';

  @override
  String get personaSettingsDescription =>
      'Nakonfigurujte si režim aktivní persony, vlastní zobrazovanou značku a spravujte jednotlivé persony.';

  @override
  String get personaDisplayTagSection => 'Zobrazovaná značka';

  @override
  String get personaDisplayTagDescription =>
      'Zobrazovaná značka se objeví vedle jmen všech person ve zprávách. Pokud není nastavena žádná zobrazovaná značka, zobrazí se vaše profilová fotka účtu.';

  @override
  String get personaDisplayTagLabel => 'Text zobrazované značky';

  @override
  String get personaDisplayTagHint => 'např. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Ikona zobrazované značky';

  @override
  String get personaUploadTagIcon => 'Nahrát ikonu';

  @override
  String get personaChangeTagIcon => 'Změnit ikonu';

  @override
  String get personaRemoveTagIcon => 'Odebrat ikonu';

  @override
  String get personaChatPreviewTitle => 'Náhled chatu';

  @override
  String get personaChatPreviewSampleMessage =>
      'Ahoj! Toto je náhled toho, jak vypadají zprávy s vaší zobrazovanou značkou a aktivní personou.';

  @override
  String get personaListTitle => 'Nakonfigurované persony';

  @override
  String get personaAddButton => 'Přidat personu';

  @override
  String get personaActiveBadge => 'Aktivní';

  @override
  String get personaMakeActive => 'Nastavit jako aktivní';

  @override
  String get personaDeleteTitle => 'Smazat personu';

  @override
  String personaDeleteMessage(String name) {
    return 'Opravdu chcete smazat „$name“? Tuto akci nelze vrátit zpět.';
  }

  @override
  String get personaDeleteConfirm => 'Smazat';

  @override
  String get personaDeletedToast => 'Persona smazána';

  @override
  String get personaCreatedToast => 'Persona vytvořena';

  @override
  String personaCreateFailedToast(String error) {
    return 'Nepodařilo se vytvořit personu: $error';
  }

  @override
  String get personaChangeAvatar => 'Změnit avatar';

  @override
  String get personaRemoveAvatar => 'Odebrat avatar';

  @override
  String get personaUploadAvatar => 'Nahrát avatar';

  @override
  String get personaTagsLabel => 'Značky persony';

  @override
  String get personaTagPrefixLabel => 'Předpona';

  @override
  String get personaTagSuffixLabel => 'Přípona';

  @override
  String get personaVisibilityLabel => 'Viditelnost';

  @override
  String get personaVisibilityUnlisted => 'Neuvedeno';

  @override
  String get personaVisibilityPublic => 'Veřejné';

  @override
  String get personaVisibilityPrivate => 'Soukromé';

  @override
  String get personaNameRequired => 'Zadejte zobrazované jméno persony';

  @override
  String get personaNameTooLong =>
      'Zobrazované jméno persony musí mít maximálně 100 znaků';

  @override
  String get personaTagPrefixTooLong =>
      'Předpona tagu persony musí mít maximálně 32 znaků';

  @override
  String get personaTagSuffixTooLong =>
      'Přípona tagu persony musí mít maximálně 32 znaků';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Tag \'$tag\' již používá \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Vložit časové razítko';

  @override
  String get timestampPickerTitle => 'Vložit časové razítko';

  @override
  String get timestampPickerInsert => 'Vložit';

  @override
  String get timestampCopied => 'Časové razítko zkopírováno';

  @override
  String get timestampPickerTimeLabel => 'Čas';

  @override
  String get timestampPickerDateLabel => 'DATUM';

  @override
  String get timestampPickerTimeSectionLabel => 'ČAS';

  @override
  String get timestampPickerTimezoneLabel => 'ČASOVÉ PÁSMO';

  @override
  String get timestampPickerFormatPreviewLabel => 'NÁHLED FORMÁTU';

  @override
  String get timestampPickerNlpPlaceholder =>
      'např. zítra v 15:00, za 2 hodiny, teď';

  @override
  String get timestampPickerSearchTimezones => 'Hledat časová pásma...';

  @override
  String get userProfileTimezoneSettingLabel => 'Časové pásmo';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Slouží k zobrazení vašeho místního času na profilu.';

  @override
  String get userProfileTimezoneNone => 'Žádné';

  @override
  String get chatReactAs => 'Reagovat jako...';

  @override
  String get emojiCopy => 'Kopírovat emoji';

  @override
  String get emojiCopyLink => 'Kopírovat odkaz';

  @override
  String get personaSignatureEmojisLabel => 'Podpisové emoji';

  @override
  String get personaSignatureEmojisDescription =>
      'Reagování podpisovým emoji vždy zareaguje jako tato persona, bez ohledu na aktivní personu.';

  @override
  String get personaAddSignatureEmoji => 'Přidat emoji';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Toto emoji je již přidáno jako podpisové emoji';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Podpisové emoji již používá persona \"$name\"';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Odebrat podpisové emoji';

  @override
  String get signalBarLabel => 'Lišta signálů';

  @override
  String get signalBarShow => 'Zobrazit lištu signálů';

  @override
  String get signalBarHide => 'Skrýt lištu signálů';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Tento signál nemá nikdo zapnutý';

  @override
  String get signalBarReset => 'Resetovat signál pro všechny';

  @override
  String signalBarTurnOff(String name) {
    return 'Vypnout $name';
  }
}
