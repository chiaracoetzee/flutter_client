// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class ForkLocalizationsHu extends ForkLocalizations {
  ForkLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Persona váltása';

  @override
  String get chatAttachmentPanelVoice => 'Hang';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'Gyorsváltó gomb';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'A hangüzenet gomb lecserélése a beviteli mezőben gyorsváltóra a gyorsabb navigációért';

  @override
  String get userSettingsCheckForUpdates => 'Frissítések keresése';

  @override
  String get userSettingsCheckingForUpdates => 'Frissítések keresése…';

  @override
  String get userSettingsAppUpToDate => 'A Fluxer naprakész';

  @override
  String get userSettingsUpdateAvailableTitle => 'Frissítés érhető el';

  @override
  String get userSettingsUpdateDownloadAction => 'Letöltés és telepítés';

  @override
  String get userSettingsUpdateInstallAction => 'Frissítés telepítése';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Frissítés letöltése ($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Nem sikerült a frissítést ellenőrizni vagy letölteni.';

  @override
  String get personaSelectTitle => 'Persona kiválasztása';

  @override
  String get personaSettingsHeader => 'Persona beállítások';

  @override
  String get personaManageAction => 'Kezelés';

  @override
  String get personaSearchPlaceholder => 'Personák, címkék, pronév keresése...';

  @override
  String get personaModeManual => 'Kézi';

  @override
  String get personaModeLast => 'Legutóbb használt';

  @override
  String get personaModeManualDescription =>
      'Mindig a kiválasztott personaként küldi el, amíg meg nem változtatod.';

  @override
  String get personaModeLastDescription =>
      'Automatikusan átvált az utolsó üzenetedben használt personára.';

  @override
  String get personaRecentHeader => 'LEGUTÓBBI PERSONÁK';

  @override
  String personaAllHeader(int count) {
    return 'ÖSSZES PERSONA ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'KERESÉSI EREDMÉNYEK ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Fő fiók (Alapértelmezett)';

  @override
  String get personaEmptyState =>
      'Még nincsenek personák beállítva. Hozz létre egyet a Personák kezelése menüpontban.';

  @override
  String get personaEmptySearch => 'Nem található megfelelő persona.';

  @override
  String get personaEditTitle => 'Persona szerkesztése';

  @override
  String get personaCreateTitle => 'Persona létrehozása';

  @override
  String get personaDisplayNameLabel => 'Megjelenítendő név';

  @override
  String get personaPronounsLabel => 'Névmások';

  @override
  String get personaPronounsHint => 'pl. ő/ők';

  @override
  String get personaBioHint => 'Mesélj másoknak erről a personáról...';

  @override
  String get personaUpdatedToast => 'Persona frissítve';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Nem sikerült frissíteni a personát: $error';
  }

  @override
  String get personaSectionTitle => 'Personák';

  @override
  String get personaDisplayNameHint => 'Persona neve';

  @override
  String personaSendingAsTag(String name) {
    return 'Küldés mint $name (Címke alapján)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Küldés mint $name (Rögzítve)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Küldés mint @$username';
  }

  @override
  String get personaMainAccount => 'Fő fiók';

  @override
  String get personaEditPersona => 'Persona szerkesztése';

  @override
  String get userSettingsNavPersonas => 'Personák';

  @override
  String get personaSettingsDescription =>
      'Állítsd be az aktív persona módot, az egyéni megjelenítési címkét, és kezeld az egyéni personákat.';

  @override
  String get personaDisplayTagSection => 'Megjelenítési címke';

  @override
  String get personaDisplayTagDescription =>
      'A megjelenítési címke minden persona neve mellett megjelenik az üzenetekben. Ha nincs beállítva megjelenítési címke, a fiókod profilképe fog megjelenni.';

  @override
  String get personaDisplayTagLabel => 'Megjelenítési címke szövege';

  @override
  String get personaDisplayTagHint => 'pl. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Megjelenítési címke ikonja';

  @override
  String get personaUploadTagIcon => 'Ikon feltöltése';

  @override
  String get personaChangeTagIcon => 'Ikon módosítása';

  @override
  String get personaRemoveTagIcon => 'Ikon eltávolítása';

  @override
  String get personaChatPreviewTitle => 'Csevegés előnézete';

  @override
  String get personaChatPreviewSampleMessage =>
      'Helló! Ez egy előnézet arról, hogyan fognak kinézni az üzenetek a megjelenítési címkéddel és az aktív personáddal.';

  @override
  String get personaListTitle => 'Beállított personák';

  @override
  String get personaAddButton => 'Persona hozzáadása';

  @override
  String get personaActiveBadge => 'Aktív';

  @override
  String get personaMakeActive => 'Beállítás aktívként';

  @override
  String get personaDeleteTitle => 'Persona törlése';

  @override
  String personaDeleteMessage(String name) {
    return 'Biztosan törölni szeretnéd a(z) „$name” personát? Ezt a műveletet nem lehet visszavonni.';
  }

  @override
  String get personaDeleteConfirm => 'Törlés';

  @override
  String get personaDeletedToast => 'Persona törölve';

  @override
  String get personaCreatedToast => 'Persona létrehozva';

  @override
  String personaCreateFailedToast(String error) {
    return 'Nem sikerült létrehozni a personát: $error';
  }

  @override
  String get personaChangeAvatar => 'Profilkép módosítása';

  @override
  String get personaRemoveAvatar => 'Profilkép eltávolítása';

  @override
  String get personaUploadAvatar => 'Profilkép feltöltése';

  @override
  String get personaTagsLabel => 'Persona címkék';

  @override
  String get personaTagPrefixLabel => 'Előtag';

  @override
  String get personaTagSuffixLabel => 'Utótag';

  @override
  String get personaVisibilityLabel => 'Láthatóság';

  @override
  String get personaVisibilityUnlisted => 'Nem listázott';

  @override
  String get personaVisibilityPublic => 'Nyilvános';

  @override
  String get personaVisibilityPrivate => 'Privát';

  @override
  String get personaNameRequired =>
      'Kérjük, add meg a persona megjelenített nevét';

  @override
  String get personaNameTooLong =>
      'A persona megjelenített neve legfeljebb 100 karakter lehet';

  @override
  String get personaTagPrefixTooLong =>
      'A persona címke előtagja legfeljebb 32 karakter lehet';

  @override
  String get personaTagSuffixTooLong =>
      'A persona címke utótagja legfeljebb 32 karakter lehet';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'A(z) \'$tag\' címkét már használja \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Időbélyegző beszúrása';

  @override
  String get timestampPickerTitle => 'Időbélyegző beszúrása';

  @override
  String get timestampPickerInsert => 'Beszúrás';

  @override
  String get timestampCopied => 'Időbélyegző másolva';

  @override
  String get timestampPickerTimeLabel => 'Idő';

  @override
  String get timestampPickerDateLabel => 'DÁTUM';

  @override
  String get timestampPickerTimeSectionLabel => 'IDŐPONT';

  @override
  String get timestampPickerTimezoneLabel => 'IDŐZÓNA';

  @override
  String get timestampPickerFormatPreviewLabel => 'FORMÁTUM ELŐNÉZETE';

  @override
  String get timestampPickerNlpPlaceholder =>
      'pl. holnap 15:00-kor, 2 óra múlva, most';

  @override
  String get timestampPickerSearchTimezones => 'Időzónák keresése...';

  @override
  String get userProfileTimezoneSettingLabel => 'Időzóna';

  @override
  String get userProfileTimezoneSettingDescription =>
      'A helyi idő megjelenítésére szolgál a profilodban.';

  @override
  String get userProfileTimezoneNone => 'Nincs';

  @override
  String get chatReactAs => 'Reakció mint...';

  @override
  String get emojiCopy => 'Emoji másolása';

  @override
  String get emojiCopyLink => 'Link másolása';

  @override
  String get personaSignatureEmojisLabel => 'Aláírási hangulatjelek';

  @override
  String get personaSignatureEmojisDescription =>
      'Az aláírási hangulatjellel való reagálás mindig ezen személyként történik, a függetlenül az aktív személytől.';

  @override
  String get personaAddSignatureEmoji => 'Hangulatjel hozzáadása';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Ez a hangulatjel már hozzá van adva aláírási hangulatjelként';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Ezt az aláírási hangulatjelet már használja a(z) \"$name\" személy';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Aláírási hangulatjel eltávolítása';

  @override
  String get signalBarLabel => 'Jelzősáv';

  @override
  String get signalBarShow => 'Jelzősáv megjelenítése';

  @override
  String get signalBarHide => 'Jelzősáv elrejtése';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Senkinél sincs bekapcsolva ez a jelzés';

  @override
  String get signalBarReset => 'Jelzés visszaállítása mindenkinél';
}
