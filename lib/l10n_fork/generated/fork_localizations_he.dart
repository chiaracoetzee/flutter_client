// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class ForkLocalizationsHe extends ForkLocalizations {
  ForkLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get chatMessageChangePersona => 'החלפת פרסונה';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'Quick Switcher button';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Replace the voice message button in the message input with a Quick Switcher button for fast navigation';

  @override
  String get personaSelectTitle => 'בחר פרסונה';

  @override
  String get personaSettingsHeader => 'הגדרות פרסונה';

  @override
  String get personaManageAction => 'ניהול';

  @override
  String get personaSearchPlaceholder => 'חפש פרסונות, תגיות, כינויי גוף...';

  @override
  String get personaModeOff => 'כבוי';

  @override
  String get personaModeManual => 'ידני';

  @override
  String get personaModeLast => 'שימוש אחרון';

  @override
  String get personaModeOffDescription =>
      'שולח מהחשבון הראשי אלא אם מוקלדות תגיות פרסונה.';

  @override
  String get personaModeManualDescription =>
      'שולח תמיד בתור הפרסונה שנבחרה עד לשינוי.';

  @override
  String get personaModeLastDescription =>
      'עובר אוטומטית לפרסונה ששימשה בהודעה האחרונה שלך.';

  @override
  String get personaRecentHeader => 'פרסונות אחרונות';

  @override
  String personaAllHeader(int count) {
    return 'כל הפרסונות ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'תוצאות חיפוש ($count)';
  }

  @override
  String get personaRootAccountLabel => 'חשבון ראשי (ברירת מחדל)';

  @override
  String get personaEmptyState =>
      'עדיין לא הוגדרו פרסונות. צור אחת דרך נהל פרסונות.';

  @override
  String get personaEmptySearch => 'לא נמצאו פרסונות תואמות.';

  @override
  String get personaEditTitle => 'ערוך פרסונה';

  @override
  String get personaCreateTitle => 'צור פרסונה';

  @override
  String get personaDisplayNameLabel => 'שם לתצוגה';

  @override
  String get personaPronounsLabel => 'כינויי גוף';

  @override
  String get personaPronounsHint => 'לדוגמה: הוא/היא';

  @override
  String get personaBioLabel => 'אודות / אודותיי';

  @override
  String get personaBioHint => 'ספר לאחרים על פרסונה זו...';

  @override
  String get personaUpdatedToast => 'הפרסונה עודכנה';

  @override
  String personaUpdateFailedToast(String error) {
    return 'עדכון הפרסונה נכשל: $error';
  }

  @override
  String get personaSectionTitle => 'פרסונות';

  @override
  String get personaDisplayNameHint => 'שם הפרסונה';

  @override
  String personaSendingAsTag(String name) {
    return 'שולח בתור $name (הותאם לפי תגית)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'שולח בתור $name (נעול)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'שולח בתור @$username';
  }

  @override
  String get personaMainAccount => 'חשבון ראשי';

  @override
  String get personaEditPersona => 'ערוך פרסונה';

  @override
  String get userSettingsNavPersonas => 'פרסונות';

  @override
  String get personaSettingsDescription =>
      'הגדר את מצב הפרסונה הפעילה, תגית תצוגה מותאמת אישית ונהל פרסונות בודדות.';

  @override
  String get personaDisplayTagSection => 'תגית תצוגה';

  @override
  String get personaDisplayTagDescription =>
      'תגית התצוגה תופיע לצד כל שמות הפרסונות בהודעות. אם לא הוגדרה תגית תצוגה, תוצג תמונת הפרופיל של החשבון שלך.';

  @override
  String get personaDisplayTagLabel => 'טקסט תגית תצוגה';

  @override
  String get personaDisplayTagHint => 'לדוגמה: SYS';

  @override
  String get personaDisplayTagIconLabel => 'אייקון תגית תצוגה';

  @override
  String get personaUploadTagIcon => 'העלאת אייקון';

  @override
  String get personaChangeTagIcon => 'שינוי אייקון';

  @override
  String get personaRemoveTagIcon => 'הסר אייקון';

  @override
  String get personaChatPreviewTitle => 'תצוגה מקדימה של הצ\'אט';

  @override
  String get personaChatPreviewSampleMessage =>
      'שלום! זוהי תצוגה מקדימה של איך הודעות ייראו עם תגית התצוגה והפרסונה הפעילה שלך.';

  @override
  String get personaListTitle => 'פרסונות מוגדרות';

  @override
  String get personaAddButton => 'הוסף פרסונה';

  @override
  String get personaActiveBadge => 'פעיל';

  @override
  String get personaMakeActive => 'הגדר כפעיל';

  @override
  String get personaDeleteTitle => 'מחק פרסונה';

  @override
  String personaDeleteMessage(String name) {
    return 'האם אתה בטוח שברצונך למחוק את \"$name\"? לא ניתן לבטל פעולה זו.';
  }

  @override
  String get personaDeleteConfirm => 'מחק';

  @override
  String get personaDeletedToast => 'הפרסונה נמחקה';

  @override
  String get personaCreatedToast => 'הפרסונה נוצרה';

  @override
  String personaCreateFailedToast(String error) {
    return 'יצירת הפרסונה נכשלה: $error';
  }

  @override
  String get personaChangeAvatar => 'שנה תמונת פרופיל';

  @override
  String get personaRemoveAvatar => 'הסר תמונת פרופיל';

  @override
  String get personaUploadAvatar => 'העלה תמונת פרופיל';

  @override
  String get personaTagsLabel => 'תגיות פרסונה';

  @override
  String get personaTagPrefixLabel => 'קידומת';

  @override
  String get personaTagSuffixLabel => 'סיומת';

  @override
  String get personaVisibilityLabel => 'נראות';

  @override
  String get personaVisibilityUnlisted => 'לא רשום';

  @override
  String get personaVisibilityPublic => 'ציבורי';

  @override
  String get personaVisibilityPrivate => 'פרטי';

  @override
  String get personaNameRequired => 'נא להזין שם תצוגה לפרסונה';

  @override
  String get personaNameTooLong =>
      'שם התצוגה של הפרסונה חייב להכיל עד 100 תווים';

  @override
  String get personaTagPrefixTooLong =>
      'קידומת התגית של הפרסונה חייבת להכיל עד 32 תווים';

  @override
  String get personaTagSuffixTooLong =>
      'סיומת התגית של הפרסונה חייבת להכיל עד 32 תווים';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'התגית \'$tag\' כבר בשימוש על ידי \'$name\'.';
  }
}
