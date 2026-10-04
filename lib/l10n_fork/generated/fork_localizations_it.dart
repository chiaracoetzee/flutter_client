// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class ForkLocalizationsIt extends ForkLocalizations {
  ForkLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Cambia persona';

  @override
  String get chatAttachmentPanelVoice => 'Voce';

  @override
  String get advancedSettingQuickSwitcherButtonLabel =>
      'Pulsante selettore rapido';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Sostituisci il pulsante dei messaggi vocali nel campo di testo con un selettore rapido per una navigazione veloce';

  @override
  String get userSettingsCheckForUpdates => 'Controlla aggiornamenti';

  @override
  String get userSettingsCheckingForUpdates =>
      'Controllo aggiornamenti in corso…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer è aggiornato';

  @override
  String get userSettingsUpdateAvailableTitle => 'Aggiornamento disponibile';

  @override
  String get userSettingsUpdateDownloadAction => 'Scarica e installa';

  @override
  String get userSettingsUpdateInstallAction => 'Installa aggiornamento';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Download aggiornamento in corso ($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Impossibile verificare o scaricare l\'aggiornamento.';

  @override
  String get personaSelectTitle => 'Seleziona persona';

  @override
  String get personaSettingsHeader => 'Impostazioni personas';

  @override
  String get personaManageAction => 'Gestisci';

  @override
  String get personaSearchPlaceholder => 'Cerca personas, tag, pronomi...';

  @override
  String get personaModeManual => 'Manuale';

  @override
  String get personaModeLast => 'Usata di recente';

  @override
  String get personaModeManualDescription =>
      'Invia sempre come persona selezionata finché non viene modificata.';

  @override
  String get personaModeLastDescription =>
      'Passa automaticamente alla persona usata nel tuo ultimo messaggio.';

  @override
  String get personaRecentHeader => 'PERSONAS RECENTI';

  @override
  String personaAllHeader(int count) {
    return 'TUTTE LE PERSONAS ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'RISULTATI DELLA RICERCA ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Account principale (Predefinito)';

  @override
  String get personaEmptyState =>
      'Nessuna persona ancora configurata. Creane una tramite Gestisci personas.';

  @override
  String get personaEmptySearch => 'Nessuna persona corrispondente trovata.';

  @override
  String get personaEditTitle => 'Modifica persona';

  @override
  String get personaCreateTitle => 'Crea persona';

  @override
  String get personaDisplayNameLabel => 'Nome visualizzato';

  @override
  String get personaPronounsLabel => 'Pronomi';

  @override
  String get personaPronounsHint => 'es. lei/lui';

  @override
  String get personaBioHint => 'Racconta agli altri di questa persona...';

  @override
  String get personaUpdatedToast => 'Persona aggiornata';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Impossibile aggiornare la persona: $error';
  }

  @override
  String get personaSectionTitle => 'Personas';

  @override
  String get personaDisplayNameHint => 'Nome della persona';

  @override
  String personaSendingAsTag(String name) {
    return 'Invio come $name (Corrispondenza per tag)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Invio come $name (Fissata)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Invio come @$username';
  }

  @override
  String get personaMainAccount => 'Account principale';

  @override
  String get personaEditPersona => 'Modifica persona';

  @override
  String get userSettingsNavPersonas => 'Personas';

  @override
  String get personaSettingsDescription =>
      'Configura la modalità persona attiva, il tag di visualizzazione personalizzato e gestisci le singole personas.';

  @override
  String get personaDisplayTagSection => 'Tag di visualizzazione';

  @override
  String get personaDisplayTagDescription =>
      'Il tag di visualizzazione apparirà accanto a tutti i nomi delle personas nei messaggi. Se non imposti alcun tag, verrà mostrata l\'immagine del profilo del tuo account.';

  @override
  String get personaDisplayTagLabel => 'Testo del tag di visualizzazione';

  @override
  String get personaDisplayTagHint => 'es. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Icona del tag di visualizzazione';

  @override
  String get personaUploadTagIcon => 'Carica icona';

  @override
  String get personaChangeTagIcon => 'Cambia icona';

  @override
  String get personaRemoveTagIcon => 'Rimuovi icona';

  @override
  String get personaChatPreviewTitle => 'Anteprima della chat';

  @override
  String get personaChatPreviewSampleMessage =>
      'Ciao! Questa è un\'anteprima di come appaiono i messaggi con il tuo tag di visualizzazione e la persona attiva.';

  @override
  String get personaListTitle => 'Personas configurate';

  @override
  String get personaAddButton => 'Aggiungi persona';

  @override
  String get personaActiveBadge => 'Attiva';

  @override
  String get personaMakeActive => 'Imposta come attiva';

  @override
  String get personaDeleteTitle => 'Elimina persona';

  @override
  String personaDeleteMessage(String name) {
    return 'Vuoi davvero eliminare \"$name\"? Questa azione non può essere annullata.';
  }

  @override
  String get personaDeleteConfirm => 'Elimina';

  @override
  String get personaDeletedToast => 'Persona eliminata';

  @override
  String get personaCreatedToast => 'Persona creata';

  @override
  String personaCreateFailedToast(String error) {
    return 'Impossibile creare la persona: $error';
  }

  @override
  String get personaChangeAvatar => 'Cambia avatar';

  @override
  String get personaRemoveAvatar => 'Rimuovi avatar';

  @override
  String get personaUploadAvatar => 'Carica avatar';

  @override
  String get personaTagsLabel => 'Tag di persona';

  @override
  String get personaTagPrefixLabel => 'Prefisso';

  @override
  String get personaTagSuffixLabel => 'Suffisso';

  @override
  String get personaVisibilityLabel => 'Visibilità';

  @override
  String get personaVisibilityUnlisted => 'Non in elenco';

  @override
  String get personaVisibilityPublic => 'Pubblica';

  @override
  String get personaVisibilityPrivate => 'Privata';

  @override
  String get personaNameRequired =>
      'Inserisci un nome visualizzato per la persona';

  @override
  String get personaNameTooLong =>
      'Il nome visualizzato della persona deve contenere massimo 100 caratteri';

  @override
  String get personaTagPrefixTooLong =>
      'Il prefisso del tag della persona deve contenere massimo 32 caratteri';

  @override
  String get personaTagSuffixTooLong =>
      'Il suffisso del tag della persona deve contenere massimo 32 caratteri';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Il tag \'$tag\' è già utilizzato da \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Inserisci timestamp';

  @override
  String get timestampPickerTitle => 'Inserisci timestamp';

  @override
  String get timestampPickerInsert => 'Inserisci';

  @override
  String get timestampCopied => 'Timestamp copiato';

  @override
  String get timestampPickerTimeLabel => 'Ora';

  @override
  String get timestampPickerDateLabel => 'DATA';

  @override
  String get timestampPickerTimeSectionLabel => 'ORA';

  @override
  String get timestampPickerTimezoneLabel => 'FUSO ORARIO';

  @override
  String get timestampPickerFormatPreviewLabel => 'ANTEPRIMA FORMATO';

  @override
  String get timestampPickerNlpPlaceholder =>
      'es. domani alle 15:00, tra 2 ore, adesso';

  @override
  String get timestampPickerSearchTimezones => 'Cerca fusi orari...';

  @override
  String get userProfileTimezoneSettingLabel => 'Fuso orario';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Usato per mostrare la tua ora locale sul tuo profilo.';

  @override
  String get userProfileTimezoneNone => 'Nessuno';

  @override
  String get chatReactAs => 'Reagisci come...';

  @override
  String get emojiCopy => 'Copia emoji';

  @override
  String get emojiCopyLink => 'Copia link';

  @override
  String get personaSignatureEmojisLabel => 'Emoji distintive';

  @override
  String get personaSignatureEmojisDescription =>
      'Reagire con un\'emoji distintiva reagirà sempre come questa persona, indipendentemente dalla persona attiva.';

  @override
  String get personaAddSignatureEmoji => 'Aggiungi emoji';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Questa emoji è già stata aggiunta come emoji distintiva';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Emoji distintiva già in uso dalla persona \"$name\"';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Rimuovi emoji distintiva';

  @override
  String get signalBarLabel => 'Barra dei segnali';

  @override
  String get signalBarShow => 'Mostra barra dei segnali';

  @override
  String get signalBarHide => 'Nascondi barra dei segnali';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Nessuno ha attivato questo segnale';

  @override
  String get signalBarReset => 'Reimposta il segnale per tutti';
}
