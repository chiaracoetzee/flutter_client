// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class ForkLocalizationsDe extends ForkLocalizations {
  ForkLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Persona wechseln';

  @override
  String get chatAttachmentPanelVoice => 'Sprache';

  @override
  String get advancedSettingQuickSwitcherButtonLabel =>
      'Quick-Switcher-Schaltfläche';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Ersetze die Sprachnachrichten-Schaltfläche im Eingabefeld durch eine Quick-Switcher-Schaltfläche für schnelle Navigation';

  @override
  String get userSettingsCheckForUpdates => 'Auf Updates überprüfen';

  @override
  String get userSettingsCheckingForUpdates => 'Nach Updates suchen…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer ist auf dem neuesten Stand';

  @override
  String get userSettingsUpdateAvailableTitle => 'Update verfügbar';

  @override
  String get userSettingsUpdateDownloadAction => 'Herunterladen & installieren';

  @override
  String get userSettingsUpdateInstallAction => 'Update installieren';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Update wird heruntergeladen ($percent %)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Update konnte nicht geprüft oder heruntergeladen werden.';

  @override
  String get personaSelectTitle => 'Persona auswählen';

  @override
  String get personaSettingsHeader => 'Persona-Einstellungen';

  @override
  String get personaManageAction => 'Verwalten';

  @override
  String get personaSearchPlaceholder => 'Personas, Tags, Pronomen suchen...';

  @override
  String get personaModeManual => 'Manuell';

  @override
  String get personaModeLast => 'Zuletzt verwendet';

  @override
  String get personaModeManualDescription =>
      'Sendet immer als ausgewählte Persona, bis dies geändert wird.';

  @override
  String get personaModeLastDescription =>
      'Wechselt automatisch zu der Persona, die in deiner letzten Nachricht verwendet wurde.';

  @override
  String get personaRecentHeader => 'KÜRZLICH VERWENDETE PERSONAS';

  @override
  String personaAllHeader(int count) {
    return 'ALLE PERSONAS ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'SUCHERGEBNISSE ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Hauptaccount (Standard)';

  @override
  String get personaEmptyState =>
      'Noch keine Personas konfiguriert. Erstelle eine über „Personas verwalten“.';

  @override
  String get personaEmptySearch => 'Keine passenden Personas gefunden.';

  @override
  String get personaEditTitle => 'Persona bearbeiten';

  @override
  String get personaCreateTitle => 'Persona erstellen';

  @override
  String get personaDisplayNameLabel => 'Anzeigename';

  @override
  String get personaPronounsLabel => 'Pronomen';

  @override
  String get personaPronounsHint => 'z. B. sie/ihr';

  @override
  String get personaBioHint => 'Erzähle anderen von dieser Persona...';

  @override
  String get personaUpdatedToast => 'Persona aktualisiert';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Persona konnte nicht aktualisiert werden: $error';
  }

  @override
  String get personaSectionTitle => 'Personas';

  @override
  String get personaDisplayNameHint => 'Persona-Name';

  @override
  String personaSendingAsTag(String name) {
    return 'Senden als $name (Über Tag zugeordnet)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Senden als $name (Fixiert)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Senden als @$username';
  }

  @override
  String get personaMainAccount => 'Hauptaccount';

  @override
  String get personaEditPersona => 'Persona bearbeiten';

  @override
  String get userSettingsNavPersonas => 'Personas';

  @override
  String get personaSettingsDescription =>
      'Konfiguriere deinen aktiven Persona-Modus, dein benutzerdefiniertes Anzeige-Tag und verwalte einzelne Personas.';

  @override
  String get personaDisplayTagSection => 'Anzeige-Tag';

  @override
  String get personaDisplayTagDescription =>
      'Das Anzeige-Tag wird neben allen Persona-Namen in Nachrichten angezeigt. Wenn kein Anzeige-Tag festgelegt ist, wird dein Account-Profilbild angezeigt.';

  @override
  String get personaDisplayTagLabel => 'Anzeige-Tag-Text';

  @override
  String get personaDisplayTagHint => 'z. B. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Anzeige-Tag-Icon';

  @override
  String get personaUploadTagIcon => 'Symbol hochladen';

  @override
  String get personaChangeTagIcon => 'Symbol ändern';

  @override
  String get personaRemoveTagIcon => 'Symbol entfernen';

  @override
  String get personaChatPreviewTitle => 'Chat-Vorschau';

  @override
  String get personaChatPreviewSampleMessage =>
      'Hallo! Dies ist eine Vorschau darauf, wie Nachrichten mit deinem Anzeige-Tag und deiner aktiven Persona aussehen.';

  @override
  String get personaListTitle => 'Konfigurierte Personas';

  @override
  String get personaAddButton => 'Persona hinzufügen';

  @override
  String get personaActiveBadge => 'Aktiv';

  @override
  String get personaMakeActive => 'Als aktiv festlegen';

  @override
  String get personaDeleteTitle => 'Persona löschen';

  @override
  String personaDeleteMessage(String name) {
    return 'Möchtest du „$name“ wirklich löschen? Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get personaDeleteConfirm => 'Löschen';

  @override
  String get personaDeletedToast => 'Persona gelöscht';

  @override
  String get personaCreatedToast => 'Persona erstellt';

  @override
  String personaCreateFailedToast(String error) {
    return 'Persona konnte nicht erstellt werden: $error';
  }

  @override
  String get personaChangeAvatar => 'Avatar ändern';

  @override
  String get personaRemoveAvatar => 'Avatar entfernen';

  @override
  String get personaUploadAvatar => 'Avatar hochladen';

  @override
  String get personaTagsLabel => 'Persona-Tags';

  @override
  String get personaTagPrefixLabel => 'Präfix';

  @override
  String get personaTagSuffixLabel => 'Suffix';

  @override
  String get personaVisibilityLabel => 'Sichtbarkeit';

  @override
  String get personaVisibilityUnlisted => 'Nicht gelistet';

  @override
  String get personaVisibilityPublic => 'Öffentlich';

  @override
  String get personaVisibilityPrivate => 'Privat';

  @override
  String get personaNameRequired => 'Bitte gib einen Persona-Anzeigenamen ein';

  @override
  String get personaNameTooLong =>
      'Der Persona-Anzeigename darf maximal 100 Zeichen lang sein';

  @override
  String get personaTagPrefixTooLong =>
      'Das Persona-Tag-Präfix darf maximal 32 Zeichen lang sein';

  @override
  String get personaTagSuffixTooLong =>
      'Das Persona-Tag-Suffix darf maximal 32 Zeichen lang sein';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Das Tag „$tag“ wird bereits von „$name“ verwendet.';
  }

  @override
  String get chatInsertTimestamp => 'Zeitstempel einfügen';

  @override
  String get timestampPickerTitle => 'Zeitstempel einfügen';

  @override
  String get timestampPickerInsert => 'Einfügen';

  @override
  String get timestampCopied => 'Zeitstempel kopiert';

  @override
  String get timestampPickerTimeLabel => 'Zeit';

  @override
  String get timestampPickerDateLabel => 'DATUM';

  @override
  String get timestampPickerTimeSectionLabel => 'UHRZEIT';

  @override
  String get timestampPickerTimezoneLabel => 'ZEITZONE';

  @override
  String get timestampPickerFormatPreviewLabel => 'FORMATVORSCHAU';

  @override
  String get timestampPickerNlpPlaceholder =>
      'z. B. morgen um 15 Uhr, in 2 Stunden, jetzt';

  @override
  String get timestampPickerSearchTimezones => 'Zeitzonen suchen...';

  @override
  String get userProfileTimezoneSettingLabel => 'Zeitzone';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Wird verwendet, um Ihre Ortszeit in Ihrem Profil anzuzeigen.';

  @override
  String get userProfileTimezoneNone => 'Keine';

  @override
  String get chatReactAs => 'Reagieren als...';

  @override
  String get emojiCopy => 'Emoji kopieren';

  @override
  String get emojiCopyLink => 'Link kopieren';

  @override
  String get personaSignatureEmojisLabel => 'Signatur-Emojis';

  @override
  String get personaSignatureEmojisDescription =>
      'Reaktionen mit einem Signatur-Emoji erfolgen immer als diese Persona, unabhängig von der aktiven Persona.';

  @override
  String get personaAddSignatureEmoji => 'Emoji hinzufügen';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Dieses Emoji wurde bereits als Signatur-Emoji hinzugefügt';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Signatur-Emoji wird bereits von Persona \"$name\" verwendet';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Signatur-Emoji entfernen';

  @override
  String get signalBarLabel => 'Signalleiste';

  @override
  String get signalBarShow => 'Signalleiste einblenden';

  @override
  String get signalBarHide => 'Signalleiste ausblenden';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Niemand hat dieses Signal eingeschaltet';

  @override
  String get signalBarReset => 'Signal für alle zurücksetzen';

  @override
  String signalBarTurnOff(String name) {
    return '$name ausschalten';
  }
}
