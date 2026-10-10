// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class ForkLocalizationsPl extends ForkLocalizations {
  ForkLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Zmień personę';

  @override
  String get chatAttachmentPanelVoice => 'Głos';

  @override
  String get advancedSettingQuickSwitcherButtonLabel =>
      'Przycisk szybkiego przełączania';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Zastąp przycisk wiadomości głosowej w polu wprowadzania przyciskiem szybkiego przełącznika';

  @override
  String get userSettingsCheckForUpdates => 'Sprawdź aktualizacje';

  @override
  String get userSettingsCheckingForUpdates => 'Sprawdzanie aktualizacji…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer jest aktualny';

  @override
  String get userSettingsUpdateAvailableTitle => 'Dostępna aktualizacja';

  @override
  String get userSettingsUpdateDownloadAction => 'Pobierz i zainstaluj';

  @override
  String get userSettingsUpdateInstallAction => 'Zainstaluj aktualizację';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Pobieranie aktualizacji ($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Nie udało się sprawdzić lub pobrać aktualizacji.';

  @override
  String get personaSelectTitle => 'Wybierz personę';

  @override
  String get personaSettingsHeader => 'Ustawienia person';

  @override
  String get personaManageAction => 'Zarządzaj';

  @override
  String get personaSearchPlaceholder => 'Szukaj person, tagów, zaimków...';

  @override
  String get personaModeManual => 'Ręczny';

  @override
  String get personaModeLast => 'Ostatnio używana';

  @override
  String get personaModeManualDescription =>
      'Zawsze wysyła jako wybrana persona do momentu zmiany.';

  @override
  String get personaModeLastDescription =>
      'Automatycznie przełącza na personę użytą w ostatniej wiadomości.';

  @override
  String get personaRecentHeader => 'OSTATNIE PERSONY';

  @override
  String personaAllHeader(int count) {
    return 'WSZYSTKIE PERSONY ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'WYNIKI WYSZUKIWANIA ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Konto główne (domyślne)';

  @override
  String get personaEmptyState =>
      'Nie skonfigurowano jeszcze żadnych person. Utwórz jedną w menu „Zarządzaj personami”.';

  @override
  String get personaEmptySearch => 'Nie znaleziono pasujących person.';

  @override
  String get personaEditTitle => 'Edytuj personę';

  @override
  String get personaCreateTitle => 'Utwórz personę';

  @override
  String get personaDisplayNameLabel => 'Nazwa wyświetlana';

  @override
  String get personaPronounsLabel => 'Zaimki';

  @override
  String get personaPronounsHint => 'np. ono/jego';

  @override
  String get personaBioHint => 'Opowiedz innym o tej personie...';

  @override
  String get personaUpdatedToast => 'Zaktualizowano personę';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Nie udało się zaktualizować persony: $error';
  }

  @override
  String get personaSectionTitle => 'Persony';

  @override
  String get personaDisplayNameHint => 'Nazwa persony';

  @override
  String personaSendingAsTag(String name) {
    return 'Wysyłanie jako $name (dopasowane przez tag)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Wysyłanie jako $name (zablokowane)';
  }

  @override
  String personaSendingAs(String name) {
    return 'Wysyłanie jako $name';
  }

  @override
  String personaPostingAs(String name) {
    return 'Publikowanie jako $name';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Wysyłanie jako @$username';
  }

  @override
  String get personaMainAccount => 'Konto główne';

  @override
  String get personaEditPersona => 'Edytuj personę';

  @override
  String get userSettingsNavPersonas => 'Persony';

  @override
  String get personaSettingsDescription =>
      'Skonfiguruj tryb aktywnej persony, własny widoczny tag i zarządzaj poszczególnymi personami.';

  @override
  String get personaDisplayTagSection => 'Widoczny tag';

  @override
  String get personaDisplayTagDescription =>
      'Widoczny tag pojawi się obok nazw wszystkich person w wiadomościach. Jeśli nie ustawiono tagu, zostanie pokazane zdjęcie profilowe twojego konta.';

  @override
  String get personaDisplayTagLabel => 'Tekst widocznego tagu';

  @override
  String get personaDisplayTagHint => 'np. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Ikona widocznego tagu';

  @override
  String get personaUploadTagIcon => 'Prześlij ikonę';

  @override
  String get personaChangeTagIcon => 'Zmień ikonę';

  @override
  String get personaRemoveTagIcon => 'Usuń ikonę';

  @override
  String get personaChatPreviewTitle => 'Podgląd czatu';

  @override
  String get personaChatPreviewSampleMessage =>
      'Cześć! To jest podgląd tego, jak wyglądają wiadomości z twoim widocznym tagiem i aktywną personą.';

  @override
  String get personaListTitle => 'Skonfigurowane persony';

  @override
  String get personaAddButton => 'Dodaj personę';

  @override
  String get personaActiveBadge => 'Aktywna';

  @override
  String get personaMakeActive => 'Ustaw jako aktywną';

  @override
  String get personaDeleteTitle => 'Usuń personę';

  @override
  String personaDeleteMessage(String name) {
    return 'Czy na pewno chcesz usunąć „$name”? Tej operacji nie można cofnąć.';
  }

  @override
  String get personaDeleteConfirm => 'Usuń';

  @override
  String get personaDeletedToast => 'Usunięto personę';

  @override
  String get personaCreatedToast => 'Utworzono personę';

  @override
  String personaCreateFailedToast(String error) {
    return 'Nie udało się utworzyć persony: $error';
  }

  @override
  String get personaChangeAvatar => 'Zmień awatar';

  @override
  String get personaRemoveAvatar => 'Usuń awatar';

  @override
  String get personaUploadAvatar => 'Prześlij awatar';

  @override
  String get personaTagsLabel => 'Tagi persony';

  @override
  String get personaTagPrefixLabel => 'Prefiks';

  @override
  String get personaTagSuffixLabel => 'Sufiks';

  @override
  String get personaVisibilityLabel => 'Widoczność';

  @override
  String get personaVisibilityUnlisted => 'Niepubliczna';

  @override
  String get personaVisibilityPublic => 'Publiczna';

  @override
  String get personaVisibilityPrivate => 'Prywatna';

  @override
  String get personaNameRequired => 'Wprowadź wyświetlaną nazwę persony';

  @override
  String get personaNameTooLong =>
      'Wyświetlana nazwa persony może mieć maksymalnie 100 znaków';

  @override
  String get personaTagPrefixTooLong =>
      'Prefiks tagu persony może mieć maksymalnie 32 znaki';

  @override
  String get personaTagSuffixTooLong =>
      'Sufiks tagu persony może mieć maksymalnie 32 znaki';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Tag \'$tag\' jest już używany przez \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Wstaw znacznik czasu';

  @override
  String get chatAttachmentSendVoiceMessage => 'Wyślij wiadomość głosową';

  @override
  String get timestampPickerTitle => 'Wstaw znacznik czasu';

  @override
  String get timestampPickerInsert => 'Wstaw';

  @override
  String get timestampCopied => 'Znacznik czasu skopiowany';

  @override
  String get timestampPickerTimeLabel => 'Czas';

  @override
  String get timestampPickerDateLabel => 'DATA';

  @override
  String get timestampPickerTimeSectionLabel => 'GODZINA';

  @override
  String get timestampPickerTimezoneLabel => 'STREFA CZASOWA';

  @override
  String get timestampPickerFormatPreviewLabel => 'PODGLĄD FORMATU';

  @override
  String get timestampPickerNlpPlaceholder =>
      'np. jutro o 15:00, za 2 godziny, teraz';

  @override
  String get timestampPickerSearchTimezones => 'Szukaj stref czasowych...';

  @override
  String get userProfileTimezoneSettingLabel => 'Strefa czasowa';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Służy do pokazywania Twojego czasu lokalnego na profilu.';

  @override
  String get userProfileTimezoneNone => 'Brak';

  @override
  String get chatReactAs => 'Zareaguj jako...';

  @override
  String get emojiCopy => 'Kopiuj emoji';

  @override
  String get emojiCopyLink => 'Kopiuj link';

  @override
  String get personaSignatureEmojisLabel => 'Emoji podpisu';

  @override
  String get personaSignatureEmojisDescription =>
      'Reagowanie za pomocą emoji podpisu zawsze doda reakcję jako ta persona, niezależnie od aktywnej persony.';

  @override
  String get personaAddSignatureEmoji => 'Dodaj emoji';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'To emoji zostało już dodane jako emoji podpisu';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Emoji podpisu jest już używane przez personę \"$name\"';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Usuń emoji podpisu';

  @override
  String get signalBarLabel => 'Pasek sygnałów';

  @override
  String get signalBarShow => 'Pokaż pasek sygnałów';

  @override
  String get signalBarHide => 'Ukryj pasek sygnałów';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Nikt nie ma włączonego tego sygnału';

  @override
  String get signalBarReset => 'Zresetuj sygnał dla wszystkich';

  @override
  String signalBarTurnOff(String name) {
    return 'Wyłącz $name';
  }

  @override
  String instanceUrlHelperDefault(String domain) {
    return 'Użyj $domain dla domyślnej instancji lub podaj dokładny adres URL innej instancji.';
  }

  @override
  String get instanceResetToDefault => 'Przywróć domyślną instancję';
}
