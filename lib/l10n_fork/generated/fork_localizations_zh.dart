// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class ForkLocalizationsZh extends ForkLocalizations {
  ForkLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get chatMessageChangePersona => '切换人格';

  @override
  String get chatAttachmentPanelVoice => '语音';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => '快速切换按钮';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      '将消息输入框中的语音消息按钮替换为快速切换按钮，以便快速导航';

  @override
  String get userSettingsCheckForUpdates => '检查更新';

  @override
  String get userSettingsCheckingForUpdates => '正在检查更新…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer 已是最新版本';

  @override
  String get userSettingsUpdateAvailableTitle => '有可用更新';

  @override
  String get userSettingsUpdateDownloadAction => '下载并安装';

  @override
  String get userSettingsUpdateInstallAction => '安装更新';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return '正在下载更新（$percent%）…';
  }

  @override
  String get userSettingsUpdateFailed => '检查或下载更新失败。';

  @override
  String get personaSelectTitle => '选择人格';

  @override
  String get personaSettingsHeader => '人格设置';

  @override
  String get personaManageAction => '管理';

  @override
  String get personaSearchPlaceholder => '搜索人格、标签、代词...';

  @override
  String get personaModeManual => '手动';

  @override
  String get personaModeLast => '最近使用';

  @override
  String get personaModeManualDescription => '在更改之前，始终以选定的人格发送。';

  @override
  String get personaModeLastDescription => '自动切换到上一条消息中使用的人格。';

  @override
  String get personaRecentHeader => '最近人格';

  @override
  String personaAllHeader(int count) {
    return '所有人格 ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return '搜索结果 ($count)';
  }

  @override
  String get personaRootAccountLabel => '根账户 (默认)';

  @override
  String get personaEmptyState => '尚未配置人格。请通过“管理人格”创建一个。';

  @override
  String get personaEmptySearch => '未找到匹配的人格。';

  @override
  String get personaEditTitle => '编辑人格';

  @override
  String get personaCreateTitle => '创建人格';

  @override
  String get personaDisplayNameLabel => '显示名称';

  @override
  String get personaPronounsLabel => '代词';

  @override
  String get personaPronounsHint => '例如：they/them';

  @override
  String get personaBioHint => '向他人介绍此人格...';

  @override
  String get personaUpdatedToast => '人格已更新';

  @override
  String personaUpdateFailedToast(String error) {
    return '更新人格失败：$error';
  }

  @override
  String get personaSectionTitle => '人格';

  @override
  String get personaDisplayNameHint => '人格名称';

  @override
  String personaSendingAsTag(String name) {
    return '以 $name 发送 (通过标签匹配)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return '以 $name 发送 (已锁定)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return '以 @$username 发送';
  }

  @override
  String get personaMainAccount => '主账户';

  @override
  String get personaEditPersona => '编辑人格';

  @override
  String get userSettingsNavPersonas => '人格';

  @override
  String get personaSettingsDescription => '配置您的活跃人格模式、自定义显示标签，并管理个人人格。';

  @override
  String get personaDisplayTagSection => '显示标签';

  @override
  String get personaDisplayTagDescription =>
      '显示标签将出现在消息中所有人格名称旁边。如果未设置显示标签，将显示您的账户头像。';

  @override
  String get personaDisplayTagLabel => '显示标签文本';

  @override
  String get personaDisplayTagHint => '例如：SYS';

  @override
  String get personaDisplayTagIconLabel => '显示标签图标';

  @override
  String get personaUploadTagIcon => '上传图标';

  @override
  String get personaChangeTagIcon => '更改图标';

  @override
  String get personaRemoveTagIcon => '移除图标';

  @override
  String get personaChatPreviewTitle => '聊天预览';

  @override
  String get personaChatPreviewSampleMessage => '你好！这是带有您的显示标签和活跃人格的消息外观预览。';

  @override
  String get personaListTitle => '已配置的人格';

  @override
  String get personaAddButton => '添加人格';

  @override
  String get personaActiveBadge => '有效';

  @override
  String get personaMakeActive => '设为活跃';

  @override
  String get personaDeleteTitle => '删除人格';

  @override
  String personaDeleteMessage(String name) {
    return '确定要删除“$name”吗？此操作无法撤销。';
  }

  @override
  String get personaDeleteConfirm => '删除';

  @override
  String get personaDeletedToast => '人格已删除';

  @override
  String get personaCreatedToast => '人格已创建';

  @override
  String personaCreateFailedToast(String error) {
    return '创建人格失败：$error';
  }

  @override
  String get personaChangeAvatar => '更换头像';

  @override
  String get personaRemoveAvatar => '移除头像';

  @override
  String get personaUploadAvatar => '上传头像';

  @override
  String get personaTagsLabel => '人格标签';

  @override
  String get personaTagPrefixLabel => '前缀';

  @override
  String get personaTagSuffixLabel => '后缀';

  @override
  String get personaVisibilityLabel => '可见性';

  @override
  String get personaVisibilityUnlisted => '未列出';

  @override
  String get personaVisibilityPublic => '公开';

  @override
  String get personaVisibilityPrivate => '私密';

  @override
  String get personaNameRequired => '请输入人格显示名称';

  @override
  String get personaNameTooLong => '人格显示名称不能超过 100 个字符';

  @override
  String get personaTagPrefixTooLong => '人格标签前缀不能超过 32 个字符';

  @override
  String get personaTagSuffixTooLong => '人格标签后缀不能超过 32 个字符';

  @override
  String personaTagCollisionError(String tag, String name) {
    return '标签“$tag”已被“$name”使用。';
  }

  @override
  String get chatInsertTimestamp => '插入时间戳';

  @override
  String get timestampPickerTitle => '插入时间戳';

  @override
  String get timestampPickerInsert => '插入';

  @override
  String get timestampCopied => '时间戳已复制';

  @override
  String get timestampPickerTimeLabel => '时间';

  @override
  String get timestampPickerDateLabel => '日期';

  @override
  String get timestampPickerTimeSectionLabel => '时间';

  @override
  String get timestampPickerTimezoneLabel => '时区';

  @override
  String get timestampPickerFormatPreviewLabel => '格式预览';

  @override
  String get timestampPickerNlpPlaceholder => '例如：明天下午3点，2小时后，现在';

  @override
  String get timestampPickerSearchTimezones => '搜索时区...';

  @override
  String get userProfileTimezoneSettingLabel => '时区';

  @override
  String get userProfileTimezoneSettingDescription => '用于在个人资料中显示您的当地时间。';

  @override
  String get userProfileTimezoneNone => '无';

  @override
  String get chatReactAs => '回应身份...';

  @override
  String get emojiCopy => '复制表情';

  @override
  String get emojiCopyLink => '复制链接';

  @override
  String get personaSignatureEmojisLabel => '专属表情符号';

  @override
  String get personaSignatureEmojisDescription =>
      '使用专属表情符号回应时，无论当前活跃角色是谁，都将始终以此角色身份回应。';

  @override
  String get personaAddSignatureEmoji => '添加表情符号';

  @override
  String get personaSignatureEmojiAlreadyAdded => '此表情符号已添加为专属表情符号';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return '专属表情符号已被角色“$name”使用';
  }

  @override
  String get personaRemoveSignatureEmoji => '移除专属表情符号';

  @override
  String get signalBarLabel => '信号栏';

  @override
  String get signalBarShow => '显示信号栏';

  @override
  String get signalBarHide => '隐藏信号栏';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label：$names';
  }

  @override
  String get signalBarNobody => '还没有人开启此信号';

  @override
  String get signalBarReset => '为所有人重置信号';

  @override
  String signalBarTurnOff(String name) {
    return '关闭 $name';
  }

  @override
  String instanceUrlHelperDefault(String domain) {
    return '默认实例请使用 $domain，或输入其他实例的准确 URL。';
  }

  @override
  String get instanceResetToDefault => '重置为默认实例';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class ForkLocalizationsZhHant extends ForkLocalizationsZh {
  ForkLocalizationsZhHant() : super('zh_Hant');

  @override
  String get chatMessageChangePersona => '切換人格';

  @override
  String get chatAttachmentPanelVoice => '語音';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => '快速切換按鈕';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      '將訊息輸入框中的語音訊息按鈕替換為快速切換按鈕，以便快速導航';

  @override
  String get userSettingsCheckForUpdates => '檢查更新';

  @override
  String get userSettingsCheckingForUpdates => '正在檢查更新…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer 已是最新版本';

  @override
  String get userSettingsUpdateAvailableTitle => '有可用更新';

  @override
  String get userSettingsUpdateDownloadAction => '下載並安裝';

  @override
  String get userSettingsUpdateInstallAction => '安裝更新';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return '正在下載更新（$percent%）…';
  }

  @override
  String get userSettingsUpdateFailed => '檢查或下載更新失敗。';

  @override
  String get personaSelectTitle => '選擇人格';

  @override
  String get personaSettingsHeader => '人格設定';

  @override
  String get personaManageAction => '管理';

  @override
  String get personaSearchPlaceholder => '搜尋人格、標籤、代名詞...';

  @override
  String get personaModeManual => '手動';

  @override
  String get personaModeLast => '最後使用';

  @override
  String get personaModeManualDescription => '在變更之前，一律以選定的人格傳送。';

  @override
  String get personaModeLastDescription => '自動切換至上一則訊息中使用的人格。';

  @override
  String get personaRecentHeader => '最近使用的人格';

  @override
  String personaAllHeader(int count) {
    return '所有人格 ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return '搜尋結果 ($count)';
  }

  @override
  String get personaRootAccountLabel => '根帳號 (預設)';

  @override
  String get personaEmptyState => '尚未設定任何人格。請透過「管理人格」建立一個。';

  @override
  String get personaEmptySearch => '找不到符合的人格。';

  @override
  String get personaEditTitle => '編輯人格';

  @override
  String get personaCreateTitle => '建立人格';

  @override
  String get personaDisplayNameLabel => '顯示名稱';

  @override
  String get personaPronounsLabel => '代名詞';

  @override
  String get personaPronounsHint => '例如：they/them';

  @override
  String get personaBioHint => '向其他人介紹這個人格...';

  @override
  String get personaUpdatedToast => '人格已更新';

  @override
  String personaUpdateFailedToast(String error) {
    return '更新人格失敗：$error';
  }

  @override
  String get personaSectionTitle => '人格';

  @override
  String get personaDisplayNameHint => '人格名稱';

  @override
  String personaSendingAsTag(String name) {
    return '以 $name 的身分傳送 (透過標籤比對)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return '以 $name 的身分傳送 (已鎖定)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return '以 @$username 的身分傳送';
  }

  @override
  String get personaMainAccount => '主帳號';

  @override
  String get personaEditPersona => '編輯人格';

  @override
  String get userSettingsNavPersonas => '人格';

  @override
  String get personaSettingsDescription => '設定您的活躍人格模式、自訂顯示標籤，並管理個人人格。';

  @override
  String get personaDisplayTagSection => '顯示標籤';

  @override
  String get personaDisplayTagDescription =>
      '顯示標籤會出現在訊息中所有人格名稱的旁邊。如果未設定顯示標籤，則會顯示您的帳號大頭貼。';

  @override
  String get personaDisplayTagLabel => '顯示標籤文字';

  @override
  String get personaDisplayTagHint => '例如：SYS';

  @override
  String get personaDisplayTagIconLabel => '顯示標籤圖示';

  @override
  String get personaUploadTagIcon => '上傳圖示';

  @override
  String get personaChangeTagIcon => '更換圖示';

  @override
  String get personaRemoveTagIcon => '移除圖示';

  @override
  String get personaChatPreviewTitle => '聊天預覽';

  @override
  String get personaChatPreviewSampleMessage => '你好！這是帶有您的顯示標籤和活躍人格的訊息外觀預覽。';

  @override
  String get personaListTitle => '已設定的人格';

  @override
  String get personaAddButton => '新增人格';

  @override
  String get personaActiveBadge => '啟用中';

  @override
  String get personaMakeActive => '設為活躍';

  @override
  String get personaDeleteTitle => '刪除人格';

  @override
  String personaDeleteMessage(String name) {
    return '確定要刪除「$name」嗎？此動作無法復原。';
  }

  @override
  String get personaDeleteConfirm => '刪除';

  @override
  String get personaDeletedToast => '人格已刪除';

  @override
  String get personaCreatedToast => '人格已建立';

  @override
  String personaCreateFailedToast(String error) {
    return '建立人格失敗：$error';
  }

  @override
  String get personaChangeAvatar => '更換大頭貼';

  @override
  String get personaRemoveAvatar => '移除大頭貼';

  @override
  String get personaUploadAvatar => '上傳大頭貼';

  @override
  String get personaTagsLabel => '人格標籤';

  @override
  String get personaTagPrefixLabel => '前綴';

  @override
  String get personaTagSuffixLabel => '後綴';

  @override
  String get personaVisibilityLabel => '能見度';

  @override
  String get personaVisibilityUnlisted => '不公開';

  @override
  String get personaVisibilityPublic => '公開';

  @override
  String get personaVisibilityPrivate => '私人';

  @override
  String get personaNameRequired => '請輸入人格顯示名稱';

  @override
  String get personaNameTooLong => '人格顯示名稱不得超過 100 個字元';

  @override
  String get personaTagPrefixTooLong => '人格標籤前綴不得超過 32 個字元';

  @override
  String get personaTagSuffixTooLong => '人格標籤後綴不得超過 32 個字元';

  @override
  String personaTagCollisionError(String tag, String name) {
    return '標籤「$tag」已被「$name」使用。';
  }

  @override
  String get chatInsertTimestamp => '插入時間戳記';

  @override
  String get timestampPickerTitle => '插入時間戳記';

  @override
  String get timestampPickerInsert => '插入';

  @override
  String get timestampCopied => '已複製時間戳記';

  @override
  String get timestampPickerTimeLabel => '時間';

  @override
  String get timestampPickerDateLabel => '日期';

  @override
  String get timestampPickerTimeSectionLabel => '時間';

  @override
  String get timestampPickerTimezoneLabel => '時區';

  @override
  String get timestampPickerFormatPreviewLabel => '格式預覽';

  @override
  String get timestampPickerNlpPlaceholder => '例如：明天下午3點，2小時後，現在';

  @override
  String get timestampPickerSearchTimezones => '搜尋時區...';

  @override
  String get userProfileTimezoneSettingLabel => '時區';

  @override
  String get userProfileTimezoneSettingDescription => '用於在個人檔案中顯示您的當地時間。';

  @override
  String get userProfileTimezoneNone => '無';

  @override
  String get chatReactAs => '回應身分...';

  @override
  String get emojiCopy => '複製表情符號';

  @override
  String get emojiCopyLink => '複製連結';

  @override
  String get personaSignatureEmojisLabel => '專屬表情符號';

  @override
  String get personaSignatureEmojisDescription =>
      '使用專屬表情符號回應時，無論目前啟用的角色是誰，都會一律以此角色身分回應。';

  @override
  String get personaAddSignatureEmoji => '新增表情符號';

  @override
  String get personaSignatureEmojiAlreadyAdded => '此表情符號已新增為專屬表情符號';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return '專屬表情符號已由角色「$name」使用';
  }

  @override
  String get personaRemoveSignatureEmoji => '移除專屬表情符號';

  @override
  String get signalBarLabel => '訊號列';

  @override
  String get signalBarShow => '顯示訊號列';

  @override
  String get signalBarHide => '隱藏訊號列';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label：$names';
  }

  @override
  String get signalBarNobody => '還沒有人開啟此訊號';

  @override
  String get signalBarReset => '為所有人重設訊號';

  @override
  String signalBarTurnOff(String name) {
    return '關閉 $name';
  }

  @override
  String instanceUrlHelperDefault(String domain) {
    return '預設執行個體請使用 $domain，或輸入其他執行個體的確切 URL。';
  }

  @override
  String get instanceResetToDefault => '重設為預設執行個體';
}
