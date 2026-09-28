// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class ForkLocalizationsUk extends ForkLocalizations {
  ForkLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Змінити персону';

  @override
  String get chatAttachmentPanelVoice => 'Голос';

  @override
  String get advancedSettingQuickSwitcherButtonLabel =>
      'Кнопка швидкого перемикання';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Замінити кнопку голосового повідомлення в полі введення на кнопку швидкого перемикання';

  @override
  String get userSettingsCheckForUpdates => 'Перевірити наявність оновлень';

  @override
  String get userSettingsCheckingForUpdates => 'Перевірка оновлень…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer оновлено до найновішої версії';

  @override
  String get userSettingsUpdateAvailableTitle => 'Доступне оновлення';

  @override
  String get userSettingsUpdateDownloadAction => 'Завантажити та встановити';

  @override
  String get userSettingsUpdateInstallAction => 'Встановити оновлення';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Завантаження оновлення ($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Не вдалося перевірити або завантажити оновлення.';

  @override
  String get personaSelectTitle => 'Виберіть персону';

  @override
  String get personaSettingsHeader => 'Налаштування персон';

  @override
  String get personaManageAction => 'Керувати';

  @override
  String get personaSearchPlaceholder => 'Пошук персон, тегів, займенників...';

  @override
  String get personaModeManual => 'Вручну';

  @override
  String get personaModeLast => 'Останнє використання';

  @override
  String get personaModeManualDescription =>
      'Завжди надсилати від імені вибраної персони до зміни.';

  @override
  String get personaModeLastDescription =>
      'Автоматично перемикається на персону, використану в останньому повідомленні.';

  @override
  String get personaRecentHeader => 'НЕДАВНІ ПЕРСОНИ';

  @override
  String personaAllHeader(int count) {
    return 'УСІ ПЕРСОНИ ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'РЕЗУЛЬТАТИ ПОШУКУ ($count)';
  }

  @override
  String get personaRootAccountLabel =>
      'Основний обліковий запис (за замовчуванням)';

  @override
  String get personaEmptyState =>
      'Ще немає налаштованих персон. Створіть їх у меню «Керування персонами».';

  @override
  String get personaEmptySearch => 'Не знайдено відповідних персон.';

  @override
  String get personaEditTitle => 'Редагувати персону';

  @override
  String get personaCreateTitle => 'Створити персону';

  @override
  String get personaDisplayNameLabel => 'Ім\'я для відображення';

  @override
  String get personaPronounsLabel => 'Займенники';

  @override
  String get personaPronounsHint => 'напр. вони/їх';

  @override
  String get personaBioHint => 'Розкажіть іншим про цю персону...';

  @override
  String get personaUpdatedToast => 'Персону оновлено';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Не вдалося оновити персону: $error';
  }

  @override
  String get personaSectionTitle => 'Персони';

  @override
  String get personaDisplayNameHint => 'Ім\'я персони';

  @override
  String personaSendingAsTag(String name) {
    return 'Надсилання як $name (за тегом)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Надсилання як $name (закріплено)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Надсилання як @$username';
  }

  @override
  String get personaMainAccount => 'Основний обліковий запис';

  @override
  String get personaEditPersona => 'Редагувати персону';

  @override
  String get userSettingsNavPersonas => 'Персони';

  @override
  String get personaSettingsDescription =>
      'Налаштуйте режим активної персони, значок відображення та керуйте окремими персонами.';

  @override
  String get personaDisplayTagSection => 'Значок відображення';

  @override
  String get personaDisplayTagDescription =>
      'Значок відображення з\'явиться поруч з іменами всіх персон у повідомленнях. Якщо значок не встановлено, відображатиметься зображення профілю вашого облікового запису.';

  @override
  String get personaDisplayTagLabel => 'Текст значка відображення';

  @override
  String get personaDisplayTagHint => 'напр. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Піктограма значка відображення';

  @override
  String get personaUploadTagIcon => 'Завантажити іконку';

  @override
  String get personaChangeTagIcon => 'Змінити іконку';

  @override
  String get personaRemoveTagIcon => 'Видалити іконку';

  @override
  String get personaChatPreviewTitle => 'Попередній перегляд чату';

  @override
  String get personaChatPreviewSampleMessage =>
      'Привіт! Це попередній перегляд того, як виглядають повідомлення з вашим значком відображення та активною персоною.';

  @override
  String get personaListTitle => 'Налаштовані персони';

  @override
  String get personaAddButton => 'Додати персону';

  @override
  String get personaActiveBadge => 'Активна';

  @override
  String get personaMakeActive => 'Зробити активною';

  @override
  String get personaDeleteTitle => 'Видалити персону';

  @override
  String personaDeleteMessage(String name) {
    return 'Ви впевнені, що хочете видалити «$name»? Цю дію не можна скасувати.';
  }

  @override
  String get personaDeleteConfirm => 'Видалити';

  @override
  String get personaDeletedToast => 'Персону видалено';

  @override
  String get personaCreatedToast => 'Персону створено';

  @override
  String personaCreateFailedToast(String error) {
    return 'Не вдалося створити персону: $error';
  }

  @override
  String get personaChangeAvatar => 'Змінити аватар';

  @override
  String get personaRemoveAvatar => 'Видалити аватар';

  @override
  String get personaUploadAvatar => 'Завантажити аватар';

  @override
  String get personaTagsLabel => 'Теги персони';

  @override
  String get personaTagPrefixLabel => 'Префікс';

  @override
  String get personaTagSuffixLabel => 'Суфікс';

  @override
  String get personaVisibilityLabel => 'Видимість';

  @override
  String get personaVisibilityUnlisted => 'Прихована';

  @override
  String get personaVisibilityPublic => 'Публічна';

  @override
  String get personaVisibilityPrivate => 'Приватна';

  @override
  String get personaNameRequired =>
      'Будь ласка, введіть відображуване ім\'я персони';

  @override
  String get personaNameTooLong =>
      'Відображуване ім\'я персони має містити не більше 100 символів';

  @override
  String get personaTagPrefixTooLong =>
      'Префікс тегу персони має містити не більше 32 символів';

  @override
  String get personaTagSuffixTooLong =>
      'Суфікс тегу персони має містити не більше 32 символів';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Тег \'$tag\' уже використовується персоною \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Вставити мітку часу';

  @override
  String get timestampPickerTitle => 'Вставити мітку часу';

  @override
  String get timestampPickerInsert => 'Вставити';

  @override
  String get timestampCopied => 'Мітку часу скопійовано';

  @override
  String get timestampPickerTimeLabel => 'Час';

  @override
  String get timestampPickerDateLabel => 'ДАТА';

  @override
  String get timestampPickerTimeSectionLabel => 'ЧАС';

  @override
  String get timestampPickerTimezoneLabel => 'ЧАСОВИЙ ПОЯС';

  @override
  String get timestampPickerFormatPreviewLabel => 'ПОПЕРЕДНІЙ ПЕРЕГЛЯД ФОРМАТУ';

  @override
  String get timestampPickerNlpPlaceholder =>
      'напр., завтра о 15:00, через 2 години, зараз';

  @override
  String get timestampPickerSearchTimezones => 'Шукати часові пояси...';

  @override
  String get userProfileTimezoneSettingLabel => 'Часовий пояс';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Використовується для відображення вашого місцевого часу у профілі.';

  @override
  String get userProfileTimezoneNone => 'Немає';

  @override
  String get chatReactAs => 'Відреагувати як...';

  @override
  String get emojiCopy => 'Копіювати емодзі';

  @override
  String get emojiCopyLink => 'Копіювати посилання';

  @override
  String get personaSignatureEmojisLabel => 'Фірмові емодзі';

  @override
  String get personaSignatureEmojisDescription =>
      'Реакція фірмовим емодзі завжди залишається від імені цієї персони, незалежно від активної.';

  @override
  String get personaAddSignatureEmoji => 'Додати емодзі';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Цей емодзі вже додано як фірмовий емодзі';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Фірмовий емодзі вже використовується персоною «$name»';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Видалити фірмовий емодзі';
}
