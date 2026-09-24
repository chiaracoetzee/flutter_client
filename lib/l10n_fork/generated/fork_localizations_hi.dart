// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class ForkLocalizationsHi extends ForkLocalizations {
  ForkLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get chatMessageChangePersona => 'परसोना बदलें';

  @override
  String get chatAttachmentPanelVoice => 'वॉइस';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'क्विक स्विचर बटन';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'तेज़ नेविगेशन के लिए इनपुट बॉक्स में वॉइस मैसेज बटन को क्विक स्विचर बटन से बदलें';

  @override
  String get personaSelectTitle => 'परसोना चुनें';

  @override
  String get personaSettingsHeader => 'परसोना सेटिंग्स';

  @override
  String get personaManageAction => 'मैनेज करें';

  @override
  String get personaSearchPlaceholder => 'परसोना, टैग, प्रोनाउन खोजें...';

  @override
  String get personaModeOff => 'बंद';

  @override
  String get personaModeManual => 'मैनुअल';

  @override
  String get personaModeLast => 'पिछली बार इस्तेमाल किया गया';

  @override
  String get personaModeOffDescription =>
      'जब तक परसोना टैग टाइप नहीं किए जाते, तब तक रूट अकाउंट से भेजता है।';

  @override
  String get personaModeManualDescription =>
      'बदले जाने तक हमेशा चुने गए परसोना के रूप में भेजता है।';

  @override
  String get personaModeLastDescription =>
      'आपके पिछले मैसेज में इस्तेमाल किए गए परसोना पर अपने आप स्विच हो जाता है।';

  @override
  String get personaRecentHeader => 'हालिया परसोना';

  @override
  String personaAllHeader(int count) {
    return 'सभी परसोना ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'खोज के नतीजे ($count)';
  }

  @override
  String get personaRootAccountLabel => 'रूट अकाउंट (डिफ़ॉल्ट)';

  @override
  String get personaEmptyState =>
      'अभी तक कोई परसोना कॉन्फ़िगर नहीं किया गया है। \'परसोना मैनेज करें\' के ज़रिए एक बनाएं।';

  @override
  String get personaEmptySearch => 'कोई मेल खाने वाला परसोना नहीं मिला।';

  @override
  String get personaEditTitle => 'परसोना एडिट करें';

  @override
  String get personaCreateTitle => 'परसोना बनाएँ';

  @override
  String get personaDisplayNameLabel => 'डिस्प्ले नाम';

  @override
  String get personaPronounsLabel => 'सर्वनाम';

  @override
  String get personaPronounsHint => 'जैसे वह/वे';

  @override
  String get personaBioHint => 'दूसरों को इस परसोना के बारे में बताएं...';

  @override
  String get personaUpdatedToast => 'परसोना अपडेट हो गया';

  @override
  String personaUpdateFailedToast(String error) {
    return 'परसोना अपडेट नहीं हो सका: $error';
  }

  @override
  String get personaSectionTitle => 'परसोना';

  @override
  String get personaDisplayNameHint => 'परसोना का नाम';

  @override
  String personaSendingAsTag(String name) {
    return '$name के तौर पर भेज रहे हैं (टैग द्वारा मैच किया गया)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return '$name के तौर पर भेज रहे हैं (लॉक किया गया)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return '@$username के तौर पर भेज रहे हैं';
  }

  @override
  String get personaMainAccount => 'मेन अकाउंट';

  @override
  String get personaEditPersona => 'परसोना एडिट करें';

  @override
  String get userSettingsNavPersonas => 'परसोना';

  @override
  String get personaSettingsDescription =>
      'अपना एक्टिव परसोना मोड, कस्टम डिस्प्ले टैग कॉन्फ़िगर करें और अलग-अलग परसोना मैनेज करें।';

  @override
  String get personaDisplayTagSection => 'डिस्प्ले टैग';

  @override
  String get personaDisplayTagDescription =>
      'डिस्प्ले टैग मैसेज में सभी परसोना नाम के आगे दिखाई देगा। यदि कोई डिस्प्ले टैग सेट नहीं है, तो आपकी अकाउंट प्रोफ़ाइल पिक्चर दिखाई जाएगी।';

  @override
  String get personaDisplayTagLabel => 'डिस्प्ले टैग टेक्स्ट';

  @override
  String get personaDisplayTagHint => 'जैसे SYS';

  @override
  String get personaDisplayTagIconLabel => 'डिस्प्ले टैग आइकॉन';

  @override
  String get personaUploadTagIcon => 'आइकॉन अपलोड करें';

  @override
  String get personaChangeTagIcon => 'आइकॉन बदलें';

  @override
  String get personaRemoveTagIcon => 'आइकॉन हटाएँ';

  @override
  String get personaChatPreviewTitle => 'चैट प्रीव्यू';

  @override
  String get personaChatPreviewSampleMessage =>
      'नमस्ते! यह एक प्रीव्यू है कि आपके डिस्प्ले टैग और एक्टिव परसोना के साथ मैसेज कैसे दिखते हैं।';

  @override
  String get personaListTitle => 'कॉन्फ़िगर किए गए परसोना';

  @override
  String get personaAddButton => 'परसोना जोड़ें';

  @override
  String get personaActiveBadge => 'सक्रिय';

  @override
  String get personaMakeActive => 'एक्टिव सेट करें';

  @override
  String get personaDeleteTitle => 'परसोना डिलीट करें';

  @override
  String personaDeleteMessage(String name) {
    return 'क्या आप वाकई \"$name\" को डिलीट करना चाहते हैं? इसे पहले जैसा नहीं किया जा सकता।';
  }

  @override
  String get personaDeleteConfirm => 'मिटाएँ';

  @override
  String get personaDeletedToast => 'परसोना डिलीट हो गया';

  @override
  String get personaCreatedToast => 'परसोना बन गया';

  @override
  String personaCreateFailedToast(String error) {
    return 'परसोना नहीं बनाया जा सका: $error';
  }

  @override
  String get personaChangeAvatar => 'अवतार बदलें';

  @override
  String get personaRemoveAvatar => 'अवतार हटाएँ';

  @override
  String get personaUploadAvatar => 'अवतार अपलोड करें';

  @override
  String get personaTagsLabel => 'परसोना टैग';

  @override
  String get personaTagPrefixLabel => 'Prefix';

  @override
  String get personaTagSuffixLabel => 'Suffix';

  @override
  String get personaVisibilityLabel => 'विज़िबिलिटी';

  @override
  String get personaVisibilityUnlisted => 'अनलिस्टेड';

  @override
  String get personaVisibilityPublic => 'पब्लिक';

  @override
  String get personaVisibilityPrivate => 'प्राइवेट';

  @override
  String get personaNameRequired => 'कृपया परसोना का डिस्प्ले नाम दर्ज करें';

  @override
  String get personaNameTooLong =>
      'परसोना का डिस्प्ले नाम 100 वर्ण या उससे कम होना चाहिए';

  @override
  String get personaTagPrefixTooLong =>
      'परसोना टैग उपसर्ग 32 वर्ण या उससे कम होना चाहिए';

  @override
  String get personaTagSuffixTooLong =>
      'परसोना टैग प्रत्यय 32 वर्ण या उससे कम होना चाहिए';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'टैग \'$tag\' पहले से ही \'$name\' द्वारा उपयोग में है।';
  }

  @override
  String get chatInsertTimestamp => 'समय टिकट डालें';

  @override
  String get timestampPickerTitle => 'समय टिकट डालें';

  @override
  String get timestampPickerInsert => 'डालें';

  @override
  String get timestampCopied => 'समय टिकट कॉपी किया गया';

  @override
  String get timestampPickerTimeLabel => 'समय';

  @override
  String get timestampPickerDateLabel => 'तारीख';

  @override
  String get timestampPickerTimeSectionLabel => 'समय';

  @override
  String get timestampPickerTimezoneLabel => 'समय क्षेत्र';

  @override
  String get timestampPickerFormatPreviewLabel => 'प्रारूप पूर्वावलोकन';

  @override
  String get timestampPickerNlpPlaceholder =>
      'उदा. कल दोपहर 3 बजे, 2 घंटे में, अभी';

  @override
  String get timestampPickerSearchTimezones => 'समय क्षेत्र खोजें...';

  @override
  String get userProfileTimezoneSettingLabel => 'समय क्षेत्र';

  @override
  String get userProfileTimezoneSettingDescription =>
      'आपकी प्रोफ़ाइल पर आपका स्थानीय समय दिखाने के लिए उपयोग किया जाता है।';

  @override
  String get userProfileTimezoneNone => 'कोई नहीं';
}
