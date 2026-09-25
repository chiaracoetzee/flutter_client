// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class ForkLocalizationsAr extends ForkLocalizations {
  ForkLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get chatMessageChangePersona => 'تغيير الشخصية';

  @override
  String get chatAttachmentPanelVoice => 'صوتي';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'زر التبديل السريع';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'استبدال زر الرسالة الصوتية في حقل الإدخال بزر التبديل السريع للتنقل السهل';

  @override
  String get userSettingsCheckForUpdates => 'التحقق من وجود تحديثات';

  @override
  String get userSettingsCheckingForUpdates => 'جارٍ التحقق من وجود تحديثات…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer محدّث لأحدث إصدار';

  @override
  String get userSettingsUpdateAvailableTitle => 'تحديث متوفر';

  @override
  String get userSettingsUpdateDownloadAction => 'تنزيل وتثبيت';

  @override
  String get userSettingsUpdateInstallAction => 'تثبيت التحديث';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'جارٍ تنزيل التحديث ($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed => 'فشل التحقق من التحديث أو تنزيله.';

  @override
  String get personaSelectTitle => 'اختيار الشخصية';

  @override
  String get personaSettingsHeader => 'إعدادات الشخصية';

  @override
  String get personaManageAction => 'إدارة';

  @override
  String get personaSearchPlaceholder => 'ابحث عن شخصيات، علامات، ضمائر...';

  @override
  String get personaModeOff => 'إيقاف';

  @override
  String get personaModeManual => 'يدوي';

  @override
  String get personaModeLast => 'آخر استخدام';

  @override
  String get personaModeOffDescription =>
      'يُرسل من الحساب الأساسي ما لم تتم كتابة علامات الشخصية.';

  @override
  String get personaModeManualDescription =>
      'يرسل دائمًا بالشخصية المحددة حتى يتم تغييرها.';

  @override
  String get personaModeLastDescription =>
      'التبديل تلقائيًا إلى الشخصية المستخدمة في رسالتك الأخيرة.';

  @override
  String get personaRecentHeader => 'الشخصيات الأخيرة';

  @override
  String personaAllHeader(int count) {
    return 'كل الشخصيات ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'نتائج البحث ($count)';
  }

  @override
  String get personaRootAccountLabel => 'الحساب الأساسي (افتراضي)';

  @override
  String get personaEmptyState =>
      'لم يتم تكوين شخصيات بعد. أنشئ واحدة عبر إدارة الشخصيات.';

  @override
  String get personaEmptySearch => 'لم يتم العثور على شخصيات مطابقة.';

  @override
  String get personaEditTitle => 'تعديل الشخصية';

  @override
  String get personaCreateTitle => 'إنشاء شخصية';

  @override
  String get personaDisplayNameLabel => 'اسم العرض';

  @override
  String get personaPronounsLabel => 'الضمائر';

  @override
  String get personaPronounsHint => 'مثال: هو/هي';

  @override
  String get personaBioHint => 'أخبر الآخرين عن هذه الشخصية...';

  @override
  String get personaUpdatedToast => 'تم تحديث الشخصية';

  @override
  String personaUpdateFailedToast(String error) {
    return 'فشل تحديث الشخصية: $error';
  }

  @override
  String get personaSectionTitle => 'الشخصيات';

  @override
  String get personaDisplayNameHint => 'اسم الشخصية';

  @override
  String personaSendingAsTag(String name) {
    return 'إرسال باسم $name (تمت المطابقة بواسطة العلامة)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'إرسال باسم $name (مثبّت)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'إرسال باسم @$username';
  }

  @override
  String get personaMainAccount => 'الحساب الرئيسي';

  @override
  String get personaEditPersona => 'تعديل الشخصية';

  @override
  String get userSettingsNavPersonas => 'الشخصيات';

  @override
  String get personaSettingsDescription =>
      'تكوين وضع الشخصية النشطة، وعلامة العرض المخصصة، وإدارة الشخصيات الفردية.';

  @override
  String get personaDisplayTagSection => 'علامة العرض';

  @override
  String get personaDisplayTagDescription =>
      'ستظهر علامة العرض بجوار جميع أسماء الشخصيات في الرسائل. إذا لم يتم تعيين علامة عرض، فستظهر صورة ملف تعريف حسابك.';

  @override
  String get personaDisplayTagLabel => 'نص علامة العرض';

  @override
  String get personaDisplayTagHint => 'مثل: SYS';

  @override
  String get personaDisplayTagIconLabel => 'أيقونة علامة العرض';

  @override
  String get personaUploadTagIcon => 'تحميل أيقونة';

  @override
  String get personaChangeTagIcon => 'تغيير الأيقونة';

  @override
  String get personaRemoveTagIcon => 'إزالة الأيقونة';

  @override
  String get personaChatPreviewTitle => 'معاينة الدردشة';

  @override
  String get personaChatPreviewSampleMessage =>
      'مرحبًا! هذه معاينة لكيفية ظهور الرسائل مع علامة العرض والشخصية النشطة.';

  @override
  String get personaListTitle => 'الشخصيات المكونة';

  @override
  String get personaAddButton => 'إضافة شخصية';

  @override
  String get personaActiveBadge => 'نشط';

  @override
  String get personaMakeActive => 'تعيين كنشط';

  @override
  String get personaDeleteTitle => 'حذف الشخصية';

  @override
  String personaDeleteMessage(String name) {
    return 'هل أنت متأكد أنك تريد حذف \"$name\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get personaDeleteConfirm => 'حذف';

  @override
  String get personaDeletedToast => 'تم حذف الشخصية';

  @override
  String get personaCreatedToast => 'تم إنشاء الشخصية';

  @override
  String personaCreateFailedToast(String error) {
    return 'فشل إنشاء الشخصية: $error';
  }

  @override
  String get personaChangeAvatar => 'تغيير الصورة الرمزية';

  @override
  String get personaRemoveAvatar => 'إزالة الصورة الرمزية';

  @override
  String get personaUploadAvatar => 'تحميل الصورة الرمزية';

  @override
  String get personaTagsLabel => 'علامات الشخصية';

  @override
  String get personaTagPrefixLabel => 'البادئة';

  @override
  String get personaTagSuffixLabel => 'اللاحقة';

  @override
  String get personaVisibilityLabel => 'الرؤية';

  @override
  String get personaVisibilityUnlisted => 'غير مدرج';

  @override
  String get personaVisibilityPublic => 'عام';

  @override
  String get personaVisibilityPrivate => 'خاص';

  @override
  String get personaNameRequired => 'يرجى إدخال اسم عرض الشخصية';

  @override
  String get personaNameTooLong => 'يجب أن يكون اسم عرض الشخصية 100 حرف أو أقل';

  @override
  String get personaTagPrefixTooLong =>
      'يجب أن تكون بادئة علامة الشخصية 32 حرفًا أو أقل';

  @override
  String get personaTagSuffixTooLong =>
      'يجب أن تكون لاحقة علامة الشخصية 32 حرفًا أو أقل';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'العلامة \'$tag\' مستخدمة بالفعل بواسطة \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'إدراج طابع زمني';

  @override
  String get timestampPickerTitle => 'إدراج طابع زمني';

  @override
  String get timestampPickerInsert => 'إدراج';

  @override
  String get timestampCopied => 'تم نسخ الطابع الزمني';

  @override
  String get timestampPickerTimeLabel => 'الوقت';

  @override
  String get timestampPickerDateLabel => 'التاريخ';

  @override
  String get timestampPickerTimeSectionLabel => 'الوقت';

  @override
  String get timestampPickerTimezoneLabel => 'المنطقة الزمنية';

  @override
  String get timestampPickerFormatPreviewLabel => 'معاينة التنسيق';

  @override
  String get timestampPickerNlpPlaceholder =>
      'مثال: غدًا في 3 مساءً، خلال ساعتين، الآن';

  @override
  String get timestampPickerSearchTimezones => 'البحث في المناطق الزمنية...';

  @override
  String get userProfileTimezoneSettingLabel => 'المنطقة الزمنية';

  @override
  String get userProfileTimezoneSettingDescription =>
      'تُستخدم لعرض وقتك المحلي في ملفك الشخصي.';

  @override
  String get userProfileTimezoneNone => 'بلا';
}
