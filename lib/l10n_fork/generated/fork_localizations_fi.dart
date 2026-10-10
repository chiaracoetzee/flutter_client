// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class ForkLocalizationsFi extends ForkLocalizations {
  ForkLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Vaihda persoonaa';

  @override
  String get chatAttachmentPanelVoice => 'Ääni';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'Pikavaihdin-painike';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Korvaa viestikentän ääniviestipainike pikavaihtimella nopeaa siirtymistä varten';

  @override
  String get userSettingsCheckForUpdates => 'Tarkista päivitykset';

  @override
  String get userSettingsCheckingForUpdates => 'Tarkistetaan päivityksiä…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer on ajan tasalla';

  @override
  String get userSettingsUpdateAvailableTitle => 'Päivitys saatavilla';

  @override
  String get userSettingsUpdateDownloadAction => 'Lataa ja asenna';

  @override
  String get userSettingsUpdateInstallAction => 'Asenna päivitys';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Ladataan päivitystä ($percent %)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Päivityksen tarkistaminen tai lataaminen epäonnistui.';

  @override
  String get personaSelectTitle => 'Valitse persoona';

  @override
  String get personaSettingsHeader => 'Persoona-asetukset';

  @override
  String get personaManageAction => 'Hallitse';

  @override
  String get personaSearchPlaceholder =>
      'Hae persoonia, tunnisteita, pronomineja...';

  @override
  String get personaModeManual => 'Manuaalinen';

  @override
  String get personaModeLast => 'Viimeksi käytetty';

  @override
  String get personaModeManualDescription =>
      'Lähettää aina valittuna persoonana, kunnes muutetaan.';

  @override
  String get personaModeLastDescription =>
      'Vaihtaa automaattisesti viimeisimmässä viestissäsi käytettyyn persoonaan.';

  @override
  String get personaRecentHeader => 'VIIMEAIKAISET PERSOONAT';

  @override
  String personaAllHeader(int count) {
    return 'KAIKKI PERSOONAT ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'HAKUTULOKSET ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Päätili (Oletus)';

  @override
  String get personaEmptyState =>
      'Persoonia ei ole vielä määritetty. Luo sellainen kohdasta Hallitse persoonia.';

  @override
  String get personaEmptySearch => 'Vastaavia persoonia ei löytynyt.';

  @override
  String get personaEditTitle => 'Muokkaa persoonaa';

  @override
  String get personaCreateTitle => 'Luo persoona';

  @override
  String get personaDisplayNameLabel => 'Näyttönimi';

  @override
  String get personaPronounsLabel => 'Pronominit';

  @override
  String get personaPronounsHint => 'esim. hän/hänelle';

  @override
  String get personaBioHint => 'Kerro muille tästä persoonasta...';

  @override
  String get personaUpdatedToast => 'Persoona päivitetty';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Persoonan päivittäminen epäonnistui: $error';
  }

  @override
  String get personaSectionTitle => 'Persoonat';

  @override
  String get personaDisplayNameHint => 'Persoonan nimi';

  @override
  String personaSendingAsTag(String name) {
    return 'Lähetetään nimellä $name (yhdistetty tunnisteella)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Lähetetään nimellä $name (lukittu)';
  }

  @override
  String personaSendingAs(String name) {
    return 'Lähetetään nimellä $name';
  }

  @override
  String personaPostingAs(String name) {
    return 'Julkaistaan nimellä $name';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Lähetetään tunnuksella @$username';
  }

  @override
  String get personaMainAccount => 'Päätili';

  @override
  String get personaEditPersona => 'Muokkaa persoonaa';

  @override
  String get userSettingsNavPersonas => 'Persoonat';

  @override
  String get personaSettingsDescription =>
      'Määritä aktiivisen persoonan tila, mukautettu näyttötunniste ja hallitse yksittäisiä persoonia.';

  @override
  String get personaDisplayTagSection => 'Näyttötunniste';

  @override
  String get personaDisplayTagDescription =>
      'Näyttötunniste näkyy kaikkien persoonien nimien vieressä viesteissä. Jos näyttötunnistetta ei ole asetettu, näytetään tilisi profiilikuva.';

  @override
  String get personaDisplayTagLabel => 'Näyttötunnisteen teksti';

  @override
  String get personaDisplayTagHint => 'esim. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Näyttötunnisteen kuvake';

  @override
  String get personaUploadTagIcon => 'Lataa kuvake';

  @override
  String get personaChangeTagIcon => 'Vaihda kuvake';

  @override
  String get personaRemoveTagIcon => 'Poista kuvake';

  @override
  String get personaChatPreviewTitle => 'Keskustelun esikatselu';

  @override
  String get personaChatPreviewSampleMessage =>
      'Hei! Tämä on esikatselu siitä, miltä viestit näyttävät näyttötunnisteellasi ja aktiivisella persoonallasi.';

  @override
  String get personaListTitle => 'Määritetyt persoonat';

  @override
  String get personaAddButton => 'Lisää persoona';

  @override
  String get personaActiveBadge => 'Aktiivinen';

  @override
  String get personaMakeActive => 'Aseta aktiiviseksi';

  @override
  String get personaDeleteTitle => 'Poista persoona';

  @override
  String personaDeleteMessage(String name) {
    return 'Haluatko varmasti poistaa kohteen \"$name\"? Tätä ei voi perua.';
  }

  @override
  String get personaDeleteConfirm => 'Poista';

  @override
  String get personaDeletedToast => 'Persoona poistettu';

  @override
  String get personaCreatedToast => 'Persoona luotu';

  @override
  String personaCreateFailedToast(String error) {
    return 'Persoonan luominen epäonnistui: $error';
  }

  @override
  String get personaChangeAvatar => 'Vaihda avatar';

  @override
  String get personaRemoveAvatar => 'Poista avatar';

  @override
  String get personaUploadAvatar => 'Lataa avatar';

  @override
  String get personaTagsLabel => 'Persoonatunnisteet';

  @override
  String get personaTagPrefixLabel => 'Etuliite';

  @override
  String get personaTagSuffixLabel => 'Jälkiliite';

  @override
  String get personaVisibilityLabel => 'Näkyvyys';

  @override
  String get personaVisibilityUnlisted => 'Piilotettu';

  @override
  String get personaVisibilityPublic => 'Julkinen';

  @override
  String get personaVisibilityPrivate => 'Yksityinen';

  @override
  String get personaNameRequired => 'Anna persoonan näyttönimi';

  @override
  String get personaNameTooLong =>
      'Persoonan näyttönimi saa olla enintään 100 merkkiä';

  @override
  String get personaTagPrefixTooLong =>
      'Persoonatunnisteen etuliite saa olla enintään 32 merkkiä';

  @override
  String get personaTagSuffixTooLong =>
      'Persoonatunnisteen jälkiliite saa olla enintään 32 merkkiä';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Tunniste \'$tag\' on jo käytössä persoonalla \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Lisää aikaleima';

  @override
  String get chatAttachmentSendVoiceMessage => 'Lähetä ääniviesti';

  @override
  String get timestampPickerTitle => 'Lisää aikaleima';

  @override
  String get timestampPickerInsert => 'Lisää';

  @override
  String get timestampCopied => 'Aikaleima kopioitu';

  @override
  String get timestampPickerTimeLabel => 'Aika';

  @override
  String get timestampPickerDateLabel => 'PÄIVÄMÄÄRÄ';

  @override
  String get timestampPickerTimeSectionLabel => 'AIKA';

  @override
  String get timestampPickerTimezoneLabel => 'AIKAVYÖHYKE';

  @override
  String get timestampPickerFormatPreviewLabel => 'MUODON ESIKATSELU';

  @override
  String get timestampPickerNlpPlaceholder =>
      'esim. huomenna klo 15, 2 tunnin kuluttua, nyt';

  @override
  String get timestampPickerSearchTimezones => 'Hae aikavyöhykkeitä...';

  @override
  String get userProfileTimezoneSettingLabel => 'Aikavyöhyke';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Käytetään paikallisen aikasi näyttämiseen profiilissasi.';

  @override
  String get userProfileTimezoneNone => 'Ei mitään';

  @override
  String get chatReactAs => 'Reagoi käyttäjänä...';

  @override
  String get emojiCopy => 'Kopioi emoji';

  @override
  String get emojiCopyLink => 'Kopioi linkki';

  @override
  String get personaSignatureEmojisLabel => 'Nimikkoemojit';

  @override
  String get personaSignatureEmojisDescription =>
      'Nimikkoemojilla reagoiminen reagoi aina tällä persoonalla aktiivisesta persoonasta riippumatta.';

  @override
  String get personaAddSignatureEmoji => 'Lisää emoji';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Tämä emoji on jo lisätty nimikkoemojiksi';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Nimikkoemoji on jo käytössä persoonalla \"$name\"';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Poista nimikkoemoji';

  @override
  String get signalBarLabel => 'Signaalipalkki';

  @override
  String get signalBarShow => 'Näytä signaalipalkki';

  @override
  String get signalBarHide => 'Piilota signaalipalkki';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Kenelläkään ei ole tätä signaalia päällä';

  @override
  String get signalBarReset => 'Nollaa signaali kaikilta';

  @override
  String signalBarTurnOff(String name) {
    return 'Kytke $name pois';
  }

  @override
  String instanceUrlHelperDefault(String domain) {
    return 'Käytä oletusinstanssille osoitetta $domain tai anna toisen instanssin tarkka URL-osoite.';
  }

  @override
  String get instanceResetToDefault => 'Palauta oletusinstanssi';
}
