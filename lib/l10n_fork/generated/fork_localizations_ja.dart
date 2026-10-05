// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class ForkLocalizationsJa extends ForkLocalizations {
  ForkLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get chatMessageChangePersona => 'ペルソナを変更';

  @override
  String get chatAttachmentPanelVoice => 'ボイス';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'クイックスイッチャーボタン';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'メッセージ入力欄のボイスメッセージボタンをクイックスイッチャーに置き換えて素早く移動する';

  @override
  String get userSettingsCheckForUpdates => 'アップデートを確認';

  @override
  String get userSettingsCheckingForUpdates => 'アップデートを確認中…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer は最新です';

  @override
  String get userSettingsUpdateAvailableTitle => 'アップデートが利用可能です';

  @override
  String get userSettingsUpdateDownloadAction => 'ダウンロードしてインストール';

  @override
  String get userSettingsUpdateInstallAction => 'アップデートをインストール';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'アップデートをダウンロード中（$percent%）…';
  }

  @override
  String get userSettingsUpdateFailed => 'アップデートの確認またはダウンロードに失敗しました。';

  @override
  String get personaSelectTitle => 'ペルソナを選択';

  @override
  String get personaSettingsHeader => 'ペルソナ設定';

  @override
  String get personaManageAction => '管理';

  @override
  String get personaSearchPlaceholder => 'ペルソナ、タグ、代名詞を検索...';

  @override
  String get personaModeManual => '手動';

  @override
  String get personaModeLast => '最終使用';

  @override
  String get personaModeManualDescription => '変更されるまで、常に選択したペルソナとして送信されます。';

  @override
  String get personaModeLastDescription => '前回のメッセージで使用したペルソナに自動的に切り替えます。';

  @override
  String get personaRecentHeader => '最近のペルソナ';

  @override
  String personaAllHeader(int count) {
    return 'すべてのペルソナ ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return '検索結果 ($count)';
  }

  @override
  String get personaRootAccountLabel => 'ルートアカウント (デフォルト)';

  @override
  String get personaEmptyState => 'ペルソナがまだ設定されていません。「ペルソナを管理」で作成してください。';

  @override
  String get personaEmptySearch => '一致するペルソナが見つかりません。';

  @override
  String get personaEditTitle => 'ペルソナを編集';

  @override
  String get personaCreateTitle => 'ペルソナを作成';

  @override
  String get personaDisplayNameLabel => '表示名';

  @override
  String get personaPronounsLabel => '代名詞';

  @override
  String get personaPronounsHint => '例: they/them';

  @override
  String get personaBioHint => 'このペルソナについて紹介...';

  @override
  String get personaUpdatedToast => 'ペルソナを更新しました';

  @override
  String personaUpdateFailedToast(String error) {
    return 'ペルソナの更新に失敗しました: $error';
  }

  @override
  String get personaSectionTitle => 'ペルソナ';

  @override
  String get personaDisplayNameHint => 'ペルソナ名';

  @override
  String personaSendingAsTag(String name) {
    return '$name として送信中 (タグで一致)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return '$name として送信中 (固定)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return '@$username として送信中';
  }

  @override
  String get personaMainAccount => 'メインアカウント';

  @override
  String get personaEditPersona => 'ペルソナを編集';

  @override
  String get userSettingsNavPersonas => 'ペルソナ';

  @override
  String get personaSettingsDescription =>
      'アクティブペルソナモードやカスタム表示タグを設定し、個別のペルソナを管理します。';

  @override
  String get personaDisplayTagSection => '表示タグ';

  @override
  String get personaDisplayTagDescription =>
      '表示タグはメッセージ内のすべてのペルソナ名の横に表示されます。表示タグが設定されていない場合は、アカウントのプロフィール画像が表示されます。';

  @override
  String get personaDisplayTagLabel => '表示タグのテキスト';

  @override
  String get personaDisplayTagHint => '例: SYS';

  @override
  String get personaDisplayTagIconLabel => '表示タグのアイコン';

  @override
  String get personaUploadTagIcon => 'アイコンをアップロード';

  @override
  String get personaChangeTagIcon => 'アイコンを変更';

  @override
  String get personaRemoveTagIcon => 'アイコンを削除';

  @override
  String get personaChatPreviewTitle => 'チャットプレビュー';

  @override
  String get personaChatPreviewSampleMessage =>
      'こんにちは！これは表示タグとアクティブなペルソナを使用したメッセージのプレビューです。';

  @override
  String get personaListTitle => '設定済みのペルソナ';

  @override
  String get personaAddButton => 'ペルソナを追加';

  @override
  String get personaActiveBadge => '有効';

  @override
  String get personaMakeActive => 'アクティブに設定';

  @override
  String get personaDeleteTitle => 'ペルソナを削除';

  @override
  String personaDeleteMessage(String name) {
    return '「$name」を削除してもよろしいですか？この操作は元に戻せません。';
  }

  @override
  String get personaDeleteConfirm => '削除';

  @override
  String get personaDeletedToast => 'ペルソナを削除しました';

  @override
  String get personaCreatedToast => 'ペルソナを作成しました';

  @override
  String personaCreateFailedToast(String error) {
    return 'ペルソナの作成に失敗しました: $error';
  }

  @override
  String get personaChangeAvatar => 'アバターを変更';

  @override
  String get personaRemoveAvatar => 'アバターを削除';

  @override
  String get personaUploadAvatar => 'アバターをアップロード';

  @override
  String get personaTagsLabel => 'ペルソナタグ';

  @override
  String get personaTagPrefixLabel => 'プレフィックス';

  @override
  String get personaTagSuffixLabel => 'サフィックス';

  @override
  String get personaVisibilityLabel => '公開設定';

  @override
  String get personaVisibilityUnlisted => '限定公開';

  @override
  String get personaVisibilityPublic => '公開';

  @override
  String get personaVisibilityPrivate => '非公開';

  @override
  String get personaNameRequired => 'ペルソナの表示名を入力してください';

  @override
  String get personaNameTooLong => 'ペルソナの表示名は100文字以内で入力してください';

  @override
  String get personaTagPrefixTooLong => 'ペルソナタグの接頭辞は32文字以内で入力してください';

  @override
  String get personaTagSuffixTooLong => 'ペルソナタグの接尾辞は32文字以内で入力してください';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'タグ「$tag」は既に「$name」によって使用されています。';
  }

  @override
  String get chatInsertTimestamp => 'タイムスタンプを挿入';

  @override
  String get timestampPickerTitle => 'タイムスタンプを挿入';

  @override
  String get timestampPickerInsert => '挿入';

  @override
  String get timestampCopied => 'タイムスタンプをコピーしました';

  @override
  String get timestampPickerTimeLabel => '時間';

  @override
  String get timestampPickerDateLabel => '日付';

  @override
  String get timestampPickerTimeSectionLabel => '時刻';

  @override
  String get timestampPickerTimezoneLabel => 'タイムゾーン';

  @override
  String get timestampPickerFormatPreviewLabel => '形式プレビュー';

  @override
  String get timestampPickerNlpPlaceholder => '例: 明日の午後3時、2時間後、今';

  @override
  String get timestampPickerSearchTimezones => 'タイムゾーンを検索...';

  @override
  String get userProfileTimezoneSettingLabel => 'タイムゾーン';

  @override
  String get userProfileTimezoneSettingDescription =>
      'プロフィールに現地時間を表示するために使用されます。';

  @override
  String get userProfileTimezoneNone => 'なし';

  @override
  String get chatReactAs => '別名でリアクション...';

  @override
  String get emojiCopy => '絵文字をコピー';

  @override
  String get emojiCopyLink => 'リンクをコピー';

  @override
  String get personaSignatureEmojisLabel => 'シグネチャー絵文字';

  @override
  String get personaSignatureEmojisDescription =>
      'シグネチャー絵文字でリアクションすると、アクティブなペルソナに関係なく、常にこのペルソナとしてリアクションします。';

  @override
  String get personaAddSignatureEmoji => '絵文字を追加';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'この絵文字はすでにシグネチャー絵文字として追加されています';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'シグネチャー絵文字はすでにペルソナ「$name」で使用されています';
  }

  @override
  String get personaRemoveSignatureEmoji => 'シグネチャー絵文字を削除';

  @override
  String get signalBarLabel => 'シグナルバー';

  @override
  String get signalBarShow => 'シグナルバーを表示';

  @override
  String get signalBarHide => 'シグナルバーを隠す';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label：$names';
  }

  @override
  String get signalBarNobody => 'このシグナルをオンにしている人はいません';

  @override
  String get signalBarReset => '全員のシグナルをリセット';

  @override
  String signalBarTurnOff(String name) {
    return '$name をオフにする';
  }

  @override
  String instanceUrlHelperDefault(String domain) {
    return 'デフォルトのインスタンスには $domain を使用するか、別のインスタンスの正確なURLを入力してください。';
  }

  @override
  String get instanceResetToDefault => 'デフォルトのインスタンスにリセット';
}
