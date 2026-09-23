// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class ForkLocalizationsRu extends ForkLocalizations {
  ForkLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Сменить персону';

  @override
  String get chatAttachmentPanelVoice => 'Голос';

  @override
  String get advancedSettingQuickSwitcherButtonLabel =>
      'Кнопка быстрого переключения';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Заменить кнопку голосового сообщения в поле ввода на кнопку быстрого переключения для удобной навигации';

  @override
  String get personaSelectTitle => 'Выберите персону';

  @override
  String get personaSettingsHeader => 'Настройки персон';

  @override
  String get personaManageAction => 'Управление';

  @override
  String get personaSearchPlaceholder => 'Поиск персон, тегов, местоимений...';

  @override
  String get personaModeOff => 'Выкл';

  @override
  String get personaModeManual => 'Вручную';

  @override
  String get personaModeLast => 'Последнее использование';

  @override
  String get personaModeOffDescription =>
      'Отправка с основного аккаунта, если не введены теги персоны.';

  @override
  String get personaModeManualDescription =>
      'Всегда отправлять от имени выбранной персоны до изменения.';

  @override
  String get personaModeLastDescription =>
      'Автоматически переключается на персону, использованную в последнем сообщении.';

  @override
  String get personaRecentHeader => 'НЕДАВНИЕ ПЕРСОНЫ';

  @override
  String personaAllHeader(int count) {
    return 'ВСЕ ПЕРСОНЫ ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'РЕЗУЛЬТАТЫ ПОИСКА ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Основной аккаунт (по умолчанию)';

  @override
  String get personaEmptyState =>
      'Персоны ещё не настроены. Создайте персону в меню «Управление персонами».';

  @override
  String get personaEmptySearch => 'Подходящих персон не найдено.';

  @override
  String get personaEditTitle => 'Редактировать персону';

  @override
  String get personaCreateTitle => 'Создать персону';

  @override
  String get personaDisplayNameLabel => 'Отображаемое имя';

  @override
  String get personaPronounsLabel => 'Местоимения';

  @override
  String get personaPronounsHint => 'напр. они/их';

  @override
  String get personaBioLabel => 'О себе';

  @override
  String get personaBioHint => 'Расскажите другим об этой персоне...';

  @override
  String get personaUpdatedToast => 'Персона обновлена';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Не удалось обновить персону: $error';
  }

  @override
  String get personaSectionTitle => 'Персоны';

  @override
  String get personaDisplayNameHint => 'Имя персоны';

  @override
  String personaSendingAsTag(String name) {
    return 'Отправка от имени $name (по тегу)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Отправка от имени $name (зафиксировано)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Отправка как @$username';
  }

  @override
  String get personaMainAccount => 'Основной аккаунт';

  @override
  String get personaEditPersona => 'Редактировать персону';

  @override
  String get userSettingsNavPersonas => 'Персоны';

  @override
  String get personaSettingsDescription =>
      'Настройте режим активной персоны, отображаемый тег и управляйте отдельными персонами.';

  @override
  String get personaDisplayTagSection => 'Отображаемый тег';

  @override
  String get personaDisplayTagDescription =>
      'Отображаемый тег будет появляться рядом со всеми именами персон в сообщениях. Если тег не задан, будет показываться аватар вашего аккаунта.';

  @override
  String get personaDisplayTagLabel => 'Текст отображаемого тега';

  @override
  String get personaDisplayTagHint => 'напр. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Иконка отображаемого тега';

  @override
  String get personaUploadTagIcon => 'Загрузить значок';

  @override
  String get personaChangeTagIcon => 'Изменить значок';

  @override
  String get personaRemoveTagIcon => 'Удалить значок';

  @override
  String get personaChatPreviewTitle => 'Предпросмотр чата';

  @override
  String get personaChatPreviewSampleMessage =>
      'Привет! Это пример того, как выглядят сообщения с вашим отображаемым тегом и активной персоной.';

  @override
  String get personaListTitle => 'Настроенные персоны';

  @override
  String get personaAddButton => 'Добавить персону';

  @override
  String get personaActiveBadge => 'Активна';

  @override
  String get personaMakeActive => 'Сделать активной';

  @override
  String get personaDeleteTitle => 'Удалить персону';

  @override
  String personaDeleteMessage(String name) {
    return 'Вы уверены, что хотите удалить «$name»? Это действие нельзя отменить.';
  }

  @override
  String get personaDeleteConfirm => 'Удалить';

  @override
  String get personaDeletedToast => 'Персона удалена';

  @override
  String get personaCreatedToast => 'Персона создана';

  @override
  String personaCreateFailedToast(String error) {
    return 'Не удалось создать персону: $error';
  }

  @override
  String get personaChangeAvatar => 'Изменить аватар';

  @override
  String get personaRemoveAvatar => 'Удалить аватар';

  @override
  String get personaUploadAvatar => 'Загрузить аватар';

  @override
  String get personaTagsLabel => 'Теги персоны';

  @override
  String get personaTagPrefixLabel => 'Префикс';

  @override
  String get personaTagSuffixLabel => 'Суффикс';

  @override
  String get personaVisibilityLabel => 'Видимость';

  @override
  String get personaVisibilityUnlisted => 'Скрытая';

  @override
  String get personaVisibilityPublic => 'Публичная';

  @override
  String get personaVisibilityPrivate => 'Приватная';

  @override
  String get personaNameRequired =>
      'Пожалуйста, введите отображаемое имя персоны';

  @override
  String get personaNameTooLong =>
      'Отображаемое имя персоны должно содержать не более 100 символов';

  @override
  String get personaTagPrefixTooLong =>
      'Префикс тега персоны должен содержать не более 32 символов';

  @override
  String get personaTagSuffixTooLong =>
      'Суффикс тега персоны должен содержать не более 32 символов';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Тег «$tag» уже используется персоной «$name».';
  }

  @override
  String get chatInsertTimestamp => 'Вставить метку времени';

  @override
  String get timestampPickerTitle => 'Вставить метку времени';

  @override
  String get timestampPickerInsert => 'Вставить';

  @override
  String get timestampCopied => 'Метка времени скопирована';

  @override
  String get timestampPickerTimeLabel => 'Время';

  @override
  String get timestampPickerDateLabel => 'ДАТА';

  @override
  String get timestampPickerTimeSectionLabel => 'ВРЕМЯ';

  @override
  String get timestampPickerTimezoneLabel => 'ЧАСОВОЙ ПОЯС';

  @override
  String get timestampPickerFormatPreviewLabel => 'ПРЕДПРОСМОТР ФОРМАТА';

  @override
  String get timestampPickerNlpPlaceholder =>
      'напр., завтра в 15:00, через 2 часа, сейчас';

  @override
  String get timestampPickerSearchTimezones => 'Поиск часовых поясов...';

  @override
  String get userProfileTimezoneSettingLabel => 'Часовой пояс';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Используется для отображения вашего местного времени в профиле.';

  @override
  String get userProfileTimezoneNone => 'Нет';
}
