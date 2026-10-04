// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class ForkLocalizationsLt extends ForkLocalizations {
  ForkLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Keisti personą';

  @override
  String get chatAttachmentPanelVoice => 'Garsas';

  @override
  String get advancedSettingQuickSwitcherButtonLabel =>
      'Greitojo perjungiklio mygtukas';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Pakeisti balso pranešimo mygtuką įvesties lauke greituoju perjungikliu patogesnei navigacijai';

  @override
  String get userSettingsCheckForUpdates => 'Tikrinti, ar yra naujinimų';

  @override
  String get userSettingsCheckingForUpdates => 'Tikrinama, ar yra naujinimų…';

  @override
  String get userSettingsAppUpToDate => '„Fluxer“ yra atnaujintas';

  @override
  String get userSettingsUpdateAvailableTitle => 'Yra naujinimas';

  @override
  String get userSettingsUpdateDownloadAction => 'Atsisiųsti ir įdiegti';

  @override
  String get userSettingsUpdateInstallAction => 'Įdiegti naujinimą';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Atsisiunčiamas naujinimas ($percent %)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Nepavyko patikrinti arba atsisiųsti naujinimo.';

  @override
  String get personaSelectTitle => 'Pasirinkite personą';

  @override
  String get personaSettingsHeader => 'Personų nustatymai';

  @override
  String get personaManageAction => 'Tvarkyti';

  @override
  String get personaSearchPlaceholder => 'Ieškoti personų, žymų, įvardžių...';

  @override
  String get personaModeManual => 'Rankinis';

  @override
  String get personaModeLast => 'Paskiausiai naudota';

  @override
  String get personaModeManualDescription =>
      'Visada siunčiama kaip pasirinkta persona, kol nepakeista.';

  @override
  String get personaModeLastDescription =>
      'Automatiškai persijungia į personą, naudotą paskutiniame pranešime.';

  @override
  String get personaRecentHeader => 'PASTAROSIOS PERSONOS';

  @override
  String personaAllHeader(int count) {
    return 'VISOS PERSONOS ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'PAIEŠKOS REZULTATAI ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Šakninė paskyra (Numatytoji)';

  @override
  String get personaEmptyState =>
      'Dar nėra sukonfigūruotų personų. Sukurkite skiltyje „Tvarkyti personas“.';

  @override
  String get personaEmptySearch => 'Atitinkančių personų nerasta.';

  @override
  String get personaEditTitle => 'Redaguoti personą';

  @override
  String get personaCreateTitle => 'Sukurti personą';

  @override
  String get personaDisplayNameLabel => 'Rodomasis vardas';

  @override
  String get personaPronounsLabel => 'Įvardžiai';

  @override
  String get personaPronounsHint => 'pvz., jie/jų';

  @override
  String get personaBioHint => 'Papasakokite kitiems apie šią personą...';

  @override
  String get personaUpdatedToast => 'Persona atnaujinta';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Nepavyko atnaujinti personos: $error';
  }

  @override
  String get personaSectionTitle => 'Personos';

  @override
  String get personaDisplayNameHint => 'Personos vardas';

  @override
  String personaSendingAsTag(String name) {
    return 'Siunčiama kaip $name (Atskirta pagal žymą)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Siunčiama kaip $name (Užfiksuota)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Siunčiama kaip @$username';
  }

  @override
  String get personaMainAccount => 'Pagrindinė paskyra';

  @override
  String get personaEditPersona => 'Redaguoti personą';

  @override
  String get userSettingsNavPersonas => 'Personos';

  @override
  String get personaSettingsDescription =>
      'Konfigūruokite aktyvios personos režimą, pasirinktinę rodomą žymą ir tvarkykite atskiras personas.';

  @override
  String get personaDisplayTagSection => 'Rodoma žyma';

  @override
  String get personaDisplayTagDescription =>
      'Rodoma žyma pasirodys šalia visų personų pavadinimų pranešimuose. Jei rodoma žyma nenustatyta, bus rodoma jūsų paskyros profilio nuotrauka.';

  @override
  String get personaDisplayTagLabel => 'Rodomos žymos tekstas';

  @override
  String get personaDisplayTagHint => 'pvz., SYS';

  @override
  String get personaDisplayTagIconLabel => 'Rodomos žymos piktograma';

  @override
  String get personaUploadTagIcon => 'Įkelti piktogramą';

  @override
  String get personaChangeTagIcon => 'Keisti piktogramą';

  @override
  String get personaRemoveTagIcon => 'Pašalinti piktogramą';

  @override
  String get personaChatPreviewTitle => 'Pokalbio peržiūra';

  @override
  String get personaChatPreviewSampleMessage =>
      'Sveiki! Tai peržiūra, kaip atrodo pranešimai su jūsų rodoma žyma ir aktyvia persona.';

  @override
  String get personaListTitle => 'Sukonfigūruotos personos';

  @override
  String get personaAddButton => 'Pridėti personą';

  @override
  String get personaActiveBadge => 'Aktyvus';

  @override
  String get personaMakeActive => 'Nustatyti kaip aktyvią';

  @override
  String get personaDeleteTitle => 'Ištrinti personą';

  @override
  String personaDeleteMessage(String name) {
    return 'Ar tikrai norite ištrinti „$name“? Šio veiksmo anuliuoti negalima.';
  }

  @override
  String get personaDeleteConfirm => 'Ištrinti';

  @override
  String get personaDeletedToast => 'Persona ištrinta';

  @override
  String get personaCreatedToast => 'Persona sukurta';

  @override
  String personaCreateFailedToast(String error) {
    return 'Nepavyko sukurti personos: $error';
  }

  @override
  String get personaChangeAvatar => 'Keisti avatarą';

  @override
  String get personaRemoveAvatar => 'Pašalinti avatarą';

  @override
  String get personaUploadAvatar => 'Įkelti avatarą';

  @override
  String get personaTagsLabel => 'Personos žymos';

  @override
  String get personaTagPrefixLabel => 'Priešdėlis';

  @override
  String get personaTagSuffixLabel => 'Priesaga';

  @override
  String get personaVisibilityLabel => 'Matomumas';

  @override
  String get personaVisibilityUnlisted => 'Neįtrauktas į sąrašą';

  @override
  String get personaVisibilityPublic => 'Viešas';

  @override
  String get personaVisibilityPrivate => 'Privatus';

  @override
  String get personaNameRequired => 'Įveskite personos rodomą vardą';

  @override
  String get personaNameTooLong =>
      'Personos rodomas vardas negali viršyti 100 simbolių';

  @override
  String get personaTagPrefixTooLong =>
      'Personos žymos priešdėlis negali viršyti 32 simbolių';

  @override
  String get personaTagSuffixTooLong =>
      'Personos žymos galūnė negali viršyti 32 simbolių';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Žymą „$tag“ jau naudoja „$name“.';
  }

  @override
  String get chatInsertTimestamp => 'Įterpti laiko žymą';

  @override
  String get timestampPickerTitle => 'Įterpti laiko žymą';

  @override
  String get timestampPickerInsert => 'Įterpti';

  @override
  String get timestampCopied => 'Laiko žyma nukopijuota';

  @override
  String get timestampPickerTimeLabel => 'Laikas';

  @override
  String get timestampPickerDateLabel => 'DATA';

  @override
  String get timestampPickerTimeSectionLabel => 'LAIKAS';

  @override
  String get timestampPickerTimezoneLabel => 'LAIKO JUOSTA';

  @override
  String get timestampPickerFormatPreviewLabel => 'FORMATO PERŽIŪRA';

  @override
  String get timestampPickerNlpPlaceholder =>
      'pvz., rytoj 15:00, po 2 valandų, dabar';

  @override
  String get timestampPickerSearchTimezones => 'Ieškoti laiko juostų...';

  @override
  String get userProfileTimezoneSettingLabel => 'Laiko juosta';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Naudojama vietiniam laikui rodyti jūsų profilyje.';

  @override
  String get userProfileTimezoneNone => 'Nėra';

  @override
  String get chatReactAs => 'Reaguoti kaip...';

  @override
  String get emojiCopy => 'Kopijuoti jaustuką';

  @override
  String get emojiCopyLink => 'Kopijuoti nuorodą';

  @override
  String get personaSignatureEmojisLabel => 'Parašo jaustukai';

  @override
  String get personaSignatureEmojisDescription =>
      'Reagavimas su parašo jaustuku visada reaguos kaip šis profilis, nepriklausomai nuo aktyvaus profilio.';

  @override
  String get personaAddSignatureEmoji => 'Pridėti jaustuką';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Šis jaustukas jau pridėtas kaip parašo jaustukas';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Parašo jaustuką jau naudoja profilis „$name“';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Pašalinti parašo jaustuką';

  @override
  String get signalBarLabel => 'Signalų juosta';

  @override
  String get signalBarShow => 'Rodyti signalų juostą';

  @override
  String get signalBarHide => 'Slėpti signalų juostą';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Niekas neįjungė šio signalo';

  @override
  String get signalBarReset => 'Atstatyti signalą visiems';
}
