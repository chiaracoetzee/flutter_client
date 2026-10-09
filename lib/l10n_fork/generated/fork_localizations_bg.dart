// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class ForkLocalizationsBg extends ForkLocalizations {
  ForkLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Промяна на персона';

  @override
  String get chatAttachmentPanelVoice => 'Гласово';

  @override
  String get advancedSettingQuickSwitcherButtonLabel =>
      'Бутон за бързо превключване';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Замяна на бутона за гласово съобщение с бърз превключвател за по-лесна навигация';

  @override
  String get userSettingsCheckForUpdates => 'Проверка за актуализации';

  @override
  String get userSettingsCheckingForUpdates => 'Проверка за актуализации…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer е актуален';

  @override
  String get userSettingsUpdateAvailableTitle => 'Налична е актуализация';

  @override
  String get userSettingsUpdateDownloadAction => 'Изтегляне и инсталиране';

  @override
  String get userSettingsUpdateInstallAction => 'Инсталиране на актуализацията';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Изтегляне на актуализация ($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Неуспешна проверка или изтегляне на актуализация.';

  @override
  String get personaSelectTitle => 'Изберете персона';

  @override
  String get personaSettingsHeader => 'Настройки на персоните';

  @override
  String get personaManageAction => 'Управление';

  @override
  String get personaSearchPlaceholder =>
      'Търсене на персони, тагове, местоимения...';

  @override
  String get personaModeManual => 'Ръчно';

  @override
  String get personaModeLast => 'Последно използвана';

  @override
  String get personaModeManualDescription =>
      'Винаги се изпраща като избраната персона до извършване на промяна.';

  @override
  String get personaModeLastDescription =>
      'Автоматично превключва към персоната, използвана в последното ви съобщение.';

  @override
  String get personaRecentHeader => 'СКОРОШНИ ПЕРСОНИ';

  @override
  String personaAllHeader(int count) {
    return 'ВСИЧКИ ПЕРСОНИ ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'РЕЗУЛТАТИ ОТ ТЪРСЕНЕТО ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Основен акаунт (По подразбиране)';

  @override
  String get personaEmptyState =>
      'Все още няма конфигурирани персони. Създайте в „Управление на персони“.';

  @override
  String get personaEmptySearch => 'Няма намерени съвпадащи персони.';

  @override
  String get personaEditTitle => 'Редактиране на персона';

  @override
  String get personaCreateTitle => 'Създаване на персона';

  @override
  String get personaDisplayNameLabel => 'Показвано име';

  @override
  String get personaPronounsLabel => 'Местоимения';

  @override
  String get personaPronounsHint => 'напр. те/тях';

  @override
  String get personaBioHint => 'Разкажете на другите за тази персона...';

  @override
  String get personaUpdatedToast => 'Персоната е обновена';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Неуспешно обновяване на персоната: $error';
  }

  @override
  String get personaSectionTitle => 'Персони';

  @override
  String get personaDisplayNameHint => 'Име на персоната';

  @override
  String personaSendingAsTag(String name) {
    return 'Изпращане като $name (Разпознато по таг)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Изпращане като $name (Фиксирано)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Изпращане като @$username';
  }

  @override
  String get personaMainAccount => 'Основен акаунт';

  @override
  String get personaEditPersona => 'Редактиране на персона';

  @override
  String get userSettingsNavPersonas => 'Персони';

  @override
  String get personaSettingsDescription =>
      'Конфигурирайте режима на активна персона, персонализирания таг за показване и управлявайте отделни персони.';

  @override
  String get personaDisplayTagSection => 'Таг за показване';

  @override
  String get personaDisplayTagDescription =>
      'Тагът за показване ще се появява до имената на всички персони в съобщенията. Ако няма зададен таг, ще се показва профилната снимка на вашия акаунт.';

  @override
  String get personaDisplayTagLabel => 'Текст на тага за показване';

  @override
  String get personaDisplayTagHint => 'напр. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Икона на тага за показване';

  @override
  String get personaUploadTagIcon => 'Качване на икона';

  @override
  String get personaChangeTagIcon => 'Смяна на икона';

  @override
  String get personaRemoveTagIcon => 'Премахване на икона';

  @override
  String get personaChatPreviewTitle => 'Предварителен преглед на чата';

  @override
  String get personaChatPreviewSampleMessage =>
      'Здравейте! Това е предварителен преглед как изглеждат съобщенията с вашия таг за показване и активна персона.';

  @override
  String get personaListTitle => 'Конфигурирани персони';

  @override
  String get personaAddButton => 'Добавяне на персона';

  @override
  String get personaActiveBadge => 'Активен';

  @override
  String get personaMakeActive => 'Задаване като активна';

  @override
  String get personaDeleteTitle => 'Изтриване на персона';

  @override
  String personaDeleteMessage(String name) {
    return 'Наистина ли искате да изтриете „$name“? Това действие е необратимо.';
  }

  @override
  String get personaDeleteConfirm => 'Изтриване';

  @override
  String get personaDeletedToast => 'Персоната е изтрита';

  @override
  String get personaCreatedToast => 'Персоната е създадена';

  @override
  String personaCreateFailedToast(String error) {
    return 'Неуспешно създаване на персона: $error';
  }

  @override
  String get personaChangeAvatar => 'Смяна на аватара';

  @override
  String get personaRemoveAvatar => 'Премахване на аватара';

  @override
  String get personaUploadAvatar => 'Качване на аватар';

  @override
  String get personaTagsLabel => 'Тагове на персона';

  @override
  String get personaTagPrefixLabel => 'Префикс';

  @override
  String get personaTagSuffixLabel => 'Суфикс';

  @override
  String get personaVisibilityLabel => 'Видимост';

  @override
  String get personaVisibilityUnlisted => 'Скрита';

  @override
  String get personaVisibilityPublic => 'Публична';

  @override
  String get personaVisibilityPrivate => 'Лична';

  @override
  String get personaNameRequired => 'Моля, въведете екранно име на персоната';

  @override
  String get personaNameTooLong =>
      'Екранното име на персоната трябва да е до 100 знака';

  @override
  String get personaTagPrefixTooLong =>
      'Префиксът на тага на персоната трябва да е до 32 знака';

  @override
  String get personaTagSuffixTooLong =>
      'Суфиксът на тага на персоната трябва да е до 32 знака';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Тагът \'$tag\' вече се използва от \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Вмъкване на клеймо за време';

  @override
  String get chatAttachmentSendVoiceMessage => 'Изпращане на гласово съобщение';

  @override
  String get timestampPickerTitle => 'Вмъкване на клеймо за време';

  @override
  String get timestampPickerInsert => 'Вмъкване';

  @override
  String get timestampCopied => 'Клеймото за време е копирано';

  @override
  String get timestampPickerTimeLabel => 'Час';

  @override
  String get timestampPickerDateLabel => 'ДАТА';

  @override
  String get timestampPickerTimeSectionLabel => 'ЧАС';

  @override
  String get timestampPickerTimezoneLabel => 'ЧАСОВА ЗОНА';

  @override
  String get timestampPickerFormatPreviewLabel => 'ПРЕГЛЕД НА ФОРМАТА';

  @override
  String get timestampPickerNlpPlaceholder =>
      'напр. утре в 15:00, след 2 часа, сега';

  @override
  String get timestampPickerSearchTimezones => 'Търсене на часови зони...';

  @override
  String get userProfileTimezoneSettingLabel => 'Часова зона';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Използва се за показване на вашето местно време в профила.';

  @override
  String get userProfileTimezoneNone => 'Няма';

  @override
  String get chatReactAs => 'Реагиране като...';

  @override
  String get emojiCopy => 'Копирай емоджи';

  @override
  String get emojiCopyLink => 'Копирай линка';

  @override
  String get personaSignatureEmojisLabel => 'Подписни емоджита';

  @override
  String get personaSignatureEmojisDescription =>
      'Реагирането с подписано емоджи винаги ще реагира като тази персона, независимо от активната персона.';

  @override
  String get personaAddSignatureEmoji => 'Добавяне на емоджи';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Това емоджи вече е добавено като подписано емоджи';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Подписаното емоджи вече се използва от персона \"$name\"';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Премахване на подписано емоджи';

  @override
  String get signalBarLabel => 'Лента със сигнали';

  @override
  String get signalBarShow => 'Показване на лентата със сигнали';

  @override
  String get signalBarHide => 'Скриване на лентата със сигнали';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Никой не е включил този сигнал';

  @override
  String get signalBarReset => 'Нулиране на сигнала за всички';

  @override
  String signalBarTurnOff(String name) {
    return 'Изключване на $name';
  }

  @override
  String instanceUrlHelperDefault(String domain) {
    return 'Използвайте $domain за инстанцията по подразбиране или точния URL адрес на друга инстанция.';
  }

  @override
  String get instanceResetToDefault =>
      'Възстановяване до инстанцията по подразбиране';
}
