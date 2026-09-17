// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class ForkLocalizationsHr extends ForkLocalizations {
  ForkLocalizationsHr([String locale = 'hr']) : super(locale);

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
  String get personaModeOff => 'Isključeno';

  @override
  String get personaModeManual => 'Ručno';

  @override
  String get personaModeLast => 'Zadnje korišteno';

  @override
  String get personaModeOffDescription =>
      'Šalje se s glavnog računa osim ako nisu upisane oznake persone.';

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
  String get personaBioLabel => 'O meni';

  @override
  String get personaBioHint => 'Recite drugima nešto o ovoj personi...';

  @override
  String get personaSaveChanges => 'Spremi promjene';

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
}
