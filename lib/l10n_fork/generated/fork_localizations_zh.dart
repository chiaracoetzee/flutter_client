// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class ForkLocalizationsZh extends ForkLocalizations {
  ForkLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get personaSelectTitle => '选择人格';

  @override
  String get personaSettingsHeader => '人格设置';

  @override
  String get personaManageAction => '管理';

  @override
  String get personaSearchPlaceholder => '搜索人格、标签、代词...';

  @override
  String get personaModeOff => '关';

  @override
  String get personaModeManual => '手动';

  @override
  String get personaModeLast => '最近使用';

  @override
  String get personaModeOffDescription => '除非输入人格标签，否则作为根账户发送。';

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
  String get personaBioLabel => '个人简介 / 关于我';

  @override
  String get personaBioHint => '向他人介绍此人格...';

  @override
  String get personaSaveChanges => '保存更改';

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
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class ForkLocalizationsZhHant extends ForkLocalizationsZh {
  ForkLocalizationsZhHant() : super('zh_Hant');

  @override
  String get personaSelectTitle => '選擇人格';

  @override
  String get personaSettingsHeader => '人格設定';

  @override
  String get personaManageAction => '管理';

  @override
  String get personaSearchPlaceholder => '搜尋人格、標籤、代名詞...';

  @override
  String get personaModeOff => '關閉';

  @override
  String get personaModeManual => '手動';

  @override
  String get personaModeLast => '最後使用';

  @override
  String get personaModeOffDescription => '除非輸入人格標籤，否則一律以根帳號傳送。';

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
  String get personaBioLabel => '個人簡介 / 關於我';

  @override
  String get personaBioHint => '向其他人介紹這個人格...';

  @override
  String get personaSaveChanges => '儲存變更';

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
}
