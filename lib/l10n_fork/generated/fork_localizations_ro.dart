// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class ForkLocalizationsRo extends ForkLocalizations {
  ForkLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Schimbă persona';

  @override
  String get chatAttachmentPanelVoice => 'Vocal';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'Buton comutator rapid';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Înlocuiește butonul de mesaj vocal din bara de text cu un comutator rapid pentru navigare facilă';

  @override
  String get userSettingsCheckForUpdates => 'Caută actualizări';

  @override
  String get userSettingsCheckingForUpdates => 'Se caută actualizări…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer este la zi';

  @override
  String get userSettingsUpdateAvailableTitle => 'Actualizare disponibilă';

  @override
  String get userSettingsUpdateDownloadAction => 'Descarcă și instalează';

  @override
  String get userSettingsUpdateInstallAction => 'Instalează actualizarea';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Se descarcă actualizarea ($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Nu s-a putut verifica sau descărca actualizarea.';

  @override
  String get personaSelectTitle => 'Selectează persona';

  @override
  String get personaSettingsHeader => 'Setări personas';

  @override
  String get personaManageAction => 'Gestionează';

  @override
  String get personaSearchPlaceholder => 'Caută personas, etichete, pronume...';

  @override
  String get personaModeManual => 'Manual';

  @override
  String get personaModeLast => 'Utilizată recent';

  @override
  String get personaModeManualDescription =>
      'Trimite întotdeauna ca persona selectată până când este schimbată.';

  @override
  String get personaModeLastDescription =>
      'Comută automat la persona utilizată în ultimul tău mesaj.';

  @override
  String get personaRecentHeader => 'PERSONAS RECENTE';

  @override
  String personaAllHeader(int count) {
    return 'TOATE PERSONAS ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'REZULTATELE CĂUTĂRII ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Contul principal (Implicit)';

  @override
  String get personaEmptyState =>
      'Nicio persona configurată încă. Creează una din Gestionează personas.';

  @override
  String get personaEmptySearch => 'Nu s-au găsit personas potrivite.';

  @override
  String get personaEditTitle => 'Editează persona';

  @override
  String get personaCreateTitle => 'Creează persona';

  @override
  String get personaDisplayNameLabel => 'Nume afișat';

  @override
  String get personaPronounsLabel => 'Pronume';

  @override
  String get personaPronounsHint => 'de ex. ea/el';

  @override
  String get personaBioHint => 'Spune-le celorlalți despre această persona...';

  @override
  String get personaUpdatedToast => 'Persona actualizată';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Nu s-a putut actualiza persona: $error';
  }

  @override
  String get personaSectionTitle => 'Personas';

  @override
  String get personaDisplayNameHint => 'Numele personei';

  @override
  String personaSendingAsTag(String name) {
    return 'Se trimite ca $name (Potrivire după etichetă)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Se trimite ca $name (Fixată)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Se trimite ca @$username';
  }

  @override
  String get personaMainAccount => 'Contul principal';

  @override
  String get personaEditPersona => 'Editează persona';

  @override
  String get userSettingsNavPersonas => 'Personas';

  @override
  String get personaSettingsDescription =>
      'Configurează modul activ de persona, eticheta de afișare personalizată și gestionează personas individuale.';

  @override
  String get personaDisplayTagSection => 'Etichetă de afișare';

  @override
  String get personaDisplayTagDescription =>
      'Eticheta de afișare va apărea lângă numele tuturor personas din mesaje. Dacă nu setezi nicio etichetă, se va afișa poza de profil a contului tău.';

  @override
  String get personaDisplayTagLabel => 'Textul etichetei de afișare';

  @override
  String get personaDisplayTagHint => 'de ex. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Pictograma etichetei de afișare';

  @override
  String get personaUploadTagIcon => 'Încarcă pictogramă';

  @override
  String get personaChangeTagIcon => 'Schimbă pictograma';

  @override
  String get personaRemoveTagIcon => 'Elimină pictograma';

  @override
  String get personaChatPreviewTitle => 'Previzualizare chat';

  @override
  String get personaChatPreviewSampleMessage =>
      'Bună! Aceasta este o previzualizare a modului în care arată mesajele cu eticheta ta de afișare și persona activă.';

  @override
  String get personaListTitle => 'Personas configurate';

  @override
  String get personaAddButton => 'Adaugă persona';

  @override
  String get personaActiveBadge => 'Activ';

  @override
  String get personaMakeActive => 'Setează ca activă';

  @override
  String get personaDeleteTitle => 'Șterge persona';

  @override
  String personaDeleteMessage(String name) {
    return 'Sigur dorești să ștergi „$name”? Această acțiune nu poate fi anulată.';
  }

  @override
  String get personaDeleteConfirm => 'Șterge';

  @override
  String get personaDeletedToast => 'Persona ștearsă';

  @override
  String get personaCreatedToast => 'Persona creată';

  @override
  String personaCreateFailedToast(String error) {
    return 'Nu s-a putut crea persona: $error';
  }

  @override
  String get personaChangeAvatar => 'Schimbă avatarul';

  @override
  String get personaRemoveAvatar => 'Elimină avatarul';

  @override
  String get personaUploadAvatar => 'Încarcă avatar';

  @override
  String get personaTagsLabel => 'Etichete persona';

  @override
  String get personaTagPrefixLabel => 'Prefix';

  @override
  String get personaTagSuffixLabel => 'Sufix';

  @override
  String get personaVisibilityLabel => 'Vizibilitate';

  @override
  String get personaVisibilityUnlisted => 'Nelistată';

  @override
  String get personaVisibilityPublic => 'Publică';

  @override
  String get personaVisibilityPrivate => 'Privată';

  @override
  String get personaNameRequired =>
      'Te rugăm să introduci un nume afișat pentru persona';

  @override
  String get personaNameTooLong =>
      'Numele afișat al personei trebuie să aibă maximum 100 de caractere';

  @override
  String get personaTagPrefixTooLong =>
      'Prefixul etichetei personei trebuie să aibă maximum 32 de caractere';

  @override
  String get personaTagSuffixTooLong =>
      'Sufixul etichetei personei trebuie să aibă maximum 32 de caractere';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Eticheta \'$tag\' este deja folosită de \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Inserează marcaj de timp';

  @override
  String get timestampPickerTitle => 'Inserează marcaj de timp';

  @override
  String get timestampPickerInsert => 'Inserează';

  @override
  String get timestampCopied => 'Marcaj de timp copiat';

  @override
  String get timestampPickerTimeLabel => 'Oră';

  @override
  String get timestampPickerDateLabel => 'DATĂ';

  @override
  String get timestampPickerTimeSectionLabel => 'ORĂ';

  @override
  String get timestampPickerTimezoneLabel => 'FUS ORAR';

  @override
  String get timestampPickerFormatPreviewLabel => 'PREVIZUALIZARE FORMAT';

  @override
  String get timestampPickerNlpPlaceholder =>
      'de ex. mâine la 15:00, în 2 ore, acum';

  @override
  String get timestampPickerSearchTimezones => 'Caută fusuri orare...';

  @override
  String get userProfileTimezoneSettingLabel => 'Fus orar';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Folosit pentru a afișa ora locală pe profilul tău.';

  @override
  String get userProfileTimezoneNone => 'Niciunul';

  @override
  String get chatReactAs => 'Reacționează ca...';

  @override
  String get emojiCopy => 'Copiază emoji';

  @override
  String get emojiCopyLink => 'Copiază linkul';

  @override
  String get personaSignatureEmojisLabel => 'Emoji-uri semnătură';

  @override
  String get personaSignatureEmojisDescription =>
      'Reacționarea cu un emoji semnătură va reacționa întotdeauna ca această persona, indiferent de persona activă.';

  @override
  String get personaAddSignatureEmoji => 'Adăugare emoji';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Acest emoji este deja adăugat ca emoji semnătură';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Emoji-ul semnătură este deja utilizat de persona „$name”';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Elimină emoji semnătură';

  @override
  String get signalBarLabel => 'Bara de semnale';

  @override
  String get signalBarShow => 'Afișează bara de semnale';

  @override
  String get signalBarHide => 'Ascunde bara de semnale';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Nimeni nu are acest semnal activat';

  @override
  String get signalBarReset => 'Resetează semnalul pentru toți';
}
