// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class ForkLocalizationsHr extends ForkLocalizations {
  ForkLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Promijeni personu';

  @override
  String get chatAttachmentPanelVoice => 'Glasovno';

  @override
  String get advancedSettingQuickSwitcherButtonLabel =>
      'Gumb brzog prebacivanja';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Zamijenite gumb glasovne poruke u polju za unos brzim prebacivanjem za lakšu navigaciju';

  @override
  String get userSettingsCheckForUpdates => 'Provjeri ažuriranja';

  @override
  String get userSettingsCheckingForUpdates => 'Provjera ažuriranja…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer je ažuran';

  @override
  String get userSettingsUpdateAvailableTitle => 'Dostupno ažuriranje';

  @override
  String get userSettingsUpdateDownloadAction => 'Preuzmi i instaliraj';

  @override
  String get userSettingsUpdateInstallAction => 'Instaliraj ažuriranje';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Preuzimanje ažuriranja ($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Provjera ili preuzimanje ažuriranja nije uspjelo.';

  @override
  String get personaSelectTitle => 'Odaberite personu';

  @override
  String get personaSettingsHeader => 'Postavke persona';

  @override
  String get personaManageAction => 'Upravljaj';

  @override
  String get personaSearchPlaceholder =>
      'Pretraži persone, oznake, zamjenice...';

  @override
  String get personaModeManual => 'Ručno';

  @override
  String get personaModeLast => 'Zadnje korišteno';

  @override
  String get personaModeManualDescription =>
      'Uvijek šalje kao odabrana persona dok se ne promijeni.';

  @override
  String get personaModeLastDescription =>
      'Automatski se prebacuje na personu korištenu u vašoj posljednjoj poruci.';

  @override
  String get personaRecentHeader => 'NEDAVNE PERSONE';

  @override
  String personaAllHeader(int count) {
    return 'SVE PERSONE ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'REZULTATI PRETRAŽIVANJA ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Glavni račun (Zadano)';

  @override
  String get personaEmptyState =>
      'Još nema konfiguriranih persona. Stvorite jednu u „Upravljanje personama”.';

  @override
  String get personaEmptySearch => 'Nisu pronađene odgovarajuće persone.';

  @override
  String get personaEditTitle => 'Uredi personu';

  @override
  String get personaCreateTitle => 'Stvori personu';

  @override
  String get personaDisplayNameLabel => 'Ime za prikaz';

  @override
  String get personaPronounsLabel => 'Zamjenice';

  @override
  String get personaPronounsHint => 'npr. oni/njih';

  @override
  String get personaBioHint => 'Recite drugima nešto o ovoj personi...';

  @override
  String get personaUpdatedToast => 'Persona je ažurirana';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Ažuriranje persone nije uspjelo: $error';
  }

  @override
  String get personaSectionTitle => 'Persone';

  @override
  String get personaDisplayNameHint => 'Ime persone';

  @override
  String personaSendingAsTag(String name) {
    return 'Šalje se kao $name (Upareno po oznaci)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Šalje se kao $name (Zaključano)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Šalje se kao @$username';
  }

  @override
  String get personaMainAccount => 'Glavni račun';

  @override
  String get personaEditPersona => 'Uredi personu';

  @override
  String get userSettingsNavPersonas => 'Persone';

  @override
  String get personaSettingsDescription =>
      'Konfigurirajte način aktivne persone, prilagođenu oznaku prikaza i upravljajte pojedinačnim personama.';

  @override
  String get personaDisplayTagSection => 'Oznaka prikaza';

  @override
  String get personaDisplayTagDescription =>
      'Oznaka prikaza pojavit će se pored svih imena persona u porukama. Ako oznaka prikaza nije postavljena, prikazat će se slika vašeg računa.';

  @override
  String get personaDisplayTagLabel => 'Tekst oznake prikaza';

  @override
  String get personaDisplayTagHint => 'npr. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Ikona oznake prikaza';

  @override
  String get personaUploadTagIcon => 'Učitaj ikonu';

  @override
  String get personaChangeTagIcon => 'Promijeni ikonu';

  @override
  String get personaRemoveTagIcon => 'Ukloni ikonu';

  @override
  String get personaChatPreviewTitle => 'Pretpregled razgovora';

  @override
  String get personaChatPreviewSampleMessage =>
      'Pozdrav! Ovo je pretpregled kako poruke izgledaju s vašom oznakom prikaza i aktivnom personom.';

  @override
  String get personaListTitle => 'Konfigurirane persone';

  @override
  String get personaAddButton => 'Dodaj personu';

  @override
  String get personaActiveBadge => 'Aktivno';

  @override
  String get personaMakeActive => 'Postavi kao aktivno';

  @override
  String get personaDeleteTitle => 'Izbriši personu';

  @override
  String personaDeleteMessage(String name) {
    return 'Jeste li sigurni da želite izbrisati „$name”? Ovo se ne može poništiti.';
  }

  @override
  String get personaDeleteConfirm => 'Izbriši';

  @override
  String get personaDeletedToast => 'Persona je izbrisana';

  @override
  String get personaCreatedToast => 'Persona je stvorena';

  @override
  String personaCreateFailedToast(String error) {
    return 'Stvaranje persone nije uspjelo: $error';
  }

  @override
  String get personaChangeAvatar => 'Promijeni avatar';

  @override
  String get personaRemoveAvatar => 'Ukloni avatar';

  @override
  String get personaUploadAvatar => 'Učitaj avatar';

  @override
  String get personaTagsLabel => 'Oznake persone';

  @override
  String get personaTagPrefixLabel => 'Prefiks';

  @override
  String get personaTagSuffixLabel => 'Sufiks';

  @override
  String get personaVisibilityLabel => 'Vidljivost';

  @override
  String get personaVisibilityUnlisted => 'Nenavedeno';

  @override
  String get personaVisibilityPublic => 'Javno';

  @override
  String get personaVisibilityPrivate => 'Privatno';

  @override
  String get personaNameRequired => 'Unesite prikazano ime persone';

  @override
  String get personaNameTooLong =>
      'Prikazano ime persone mora imati najviše 100 znakova';

  @override
  String get personaTagPrefixTooLong =>
      'Prefiks oznake persone mora imati najviše 32 znaka';

  @override
  String get personaTagSuffixTooLong =>
      'Sufiks oznake persone mora imati najviše 32 znaka';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Oznaku \'$tag\' već koristi \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Umetni vremensku oznaku';

  @override
  String get timestampPickerTitle => 'Umetni vremensku oznaku';

  @override
  String get timestampPickerInsert => 'Umetni';

  @override
  String get timestampCopied => 'Vremenska oznaka kopirana';

  @override
  String get timestampPickerTimeLabel => 'Vrijeme';

  @override
  String get timestampPickerDateLabel => 'DATUM';

  @override
  String get timestampPickerTimeSectionLabel => 'VRIJEME';

  @override
  String get timestampPickerTimezoneLabel => 'VREMENSKA ZONA';

  @override
  String get timestampPickerFormatPreviewLabel => 'PREGLED OBLIKA';

  @override
  String get timestampPickerNlpPlaceholder =>
      'npr. sutra u 15:00, za 2 sata, sada';

  @override
  String get timestampPickerSearchTimezones => 'Pretraži vremenske zone...';

  @override
  String get userProfileTimezoneSettingLabel => 'Vremenska zona';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Koristi se za prikaz vašeg lokalnog vremena na profilu.';

  @override
  String get userProfileTimezoneNone => 'Nijedno';

  @override
  String get chatReactAs => 'Reagiraj kao...';

  @override
  String get emojiCopy => 'Kopiraj emoji';

  @override
  String get emojiCopyLink => 'Kopiraj poveznicu';

  @override
  String get personaSignatureEmojisLabel => 'Prepoznatljivi emojiji';

  @override
  String get personaSignatureEmojisDescription =>
      'Reagiranje s prepoznatljivim emojijem uvijek će reagirati kao ova persona, bez obzira na aktivnu personu.';

  @override
  String get personaAddSignatureEmoji => 'Dodaj emoji';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Ovaj emoji je već dodan kao prepoznatljivi emoji';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Prepoznatljivi emoji već koristi persona \"$name\"';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Ukloni prepoznatljivi emoji';

  @override
  String get signalBarLabel => 'Traka signala';

  @override
  String get signalBarShow => 'Prikaži traku signala';

  @override
  String get signalBarHide => 'Sakrij traku signala';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Nitko nema uključen ovaj signal';

  @override
  String get signalBarReset => 'Poništi signal za sve';
}
