// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class ForkLocalizationsKo extends ForkLocalizations {
  ForkLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get chatMessageChangePersona => '페르소나 변경';

  @override
  String get chatAttachmentPanelVoice => '음성';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => '빠른 전환 버튼';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      '입력창의 음성 메시지 버튼을 빠른 전환 버튼으로 교체하여 편리하게 이동';

  @override
  String get userSettingsCheckForUpdates => '업데이트 확인';

  @override
  String get userSettingsCheckingForUpdates => '업데이트 확인 중…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer가 최신 상태입니다';

  @override
  String get userSettingsUpdateAvailableTitle => '업데이트 사용 가능';

  @override
  String get userSettingsUpdateDownloadAction => '다운로드 및 설치';

  @override
  String get userSettingsUpdateInstallAction => '업데이트 설치';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return '업데이트 다운로드 중($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed => '업데이트 확인 또는 다운로드에 실패했습니다.';

  @override
  String get personaSelectTitle => '페르소나 선택';

  @override
  String get personaSettingsHeader => '페르소나 설정';

  @override
  String get personaManageAction => '관리';

  @override
  String get personaSearchPlaceholder => '페르소나, 태그, 대명사 검색...';

  @override
  String get personaModeManual => '수동';

  @override
  String get personaModeLast => '최근 사용됨';

  @override
  String get personaModeManualDescription => '변경할 때까지 항상 선택한 페르소나로 전송됩니다.';

  @override
  String get personaModeLastDescription => '마지막 메시지에서 사용한 페르소나로 자동 전환됩니다.';

  @override
  String get personaRecentHeader => '최근 페르소나';

  @override
  String personaAllHeader(int count) {
    return '모든 페르소나 ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return '검색 결과 ($count)';
  }

  @override
  String get personaRootAccountLabel => '기본 계정 (기본값)';

  @override
  String get personaEmptyState => '아직 구성된 페르소나가 없습니다. 페르소나 관리에서 생성하세요.';

  @override
  String get personaEmptySearch => '일치하는 페르소나를 찾을 수 없습니다.';

  @override
  String get personaEditTitle => '페르소나 편집';

  @override
  String get personaCreateTitle => '페르소나 생성';

  @override
  String get personaDisplayNameLabel => '표시 이름';

  @override
  String get personaPronounsLabel => '대명사';

  @override
  String get personaPronounsHint => '예: they/them';

  @override
  String get personaBioHint => '이 페르소나에 대해 알려주세요...';

  @override
  String get personaUpdatedToast => '페르소나 업데이트됨';

  @override
  String personaUpdateFailedToast(String error) {
    return '페르소나 업데이트 실패: $error';
  }

  @override
  String get personaSectionTitle => '페르소나';

  @override
  String get personaDisplayNameHint => '페르소나 이름';

  @override
  String personaSendingAsTag(String name) {
    return '$name 님으로 보내는 중 (태그로 일치)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return '$name 님으로 보내는 중 (고정됨)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return '@$username 님으로 보내는 중';
  }

  @override
  String get personaMainAccount => '기본 계정';

  @override
  String get personaEditPersona => '페르소나 편집';

  @override
  String get userSettingsNavPersonas => '페르소나';

  @override
  String get personaSettingsDescription =>
      '활성 페르소나 모드와 사용자 지정 표시 태그를 구성하고 개별 페르소나를 관리하세요.';

  @override
  String get personaDisplayTagSection => '표시 태그';

  @override
  String get personaDisplayTagDescription =>
      '메시지의 모든 페르소나 이름 옆에 표시 태그가 나타납니다. 표시 태그를 설정하지 않으면 계정 프로필 사진이 표시됩니다.';

  @override
  String get personaDisplayTagLabel => '표시 태그 텍스트';

  @override
  String get personaDisplayTagHint => '예: SYS';

  @override
  String get personaDisplayTagIconLabel => '표시 태그 아이콘';

  @override
  String get personaUploadTagIcon => '아이콘 업로드';

  @override
  String get personaChangeTagIcon => '아이콘 변경';

  @override
  String get personaRemoveTagIcon => '아이콘 삭제';

  @override
  String get personaChatPreviewTitle => '채팅 미리보기';

  @override
  String get personaChatPreviewSampleMessage =>
      '안녕하세요! 표시 태그와 활성 페르소나가 적용된 메시지가 어떻게 표시되는지 보여주는 미리보기입니다.';

  @override
  String get personaListTitle => '구성된 페르소나';

  @override
  String get personaAddButton => '페르소나 추가';

  @override
  String get personaActiveBadge => '활성';

  @override
  String get personaMakeActive => '활성 상태로 설정';

  @override
  String get personaDeleteTitle => '페르소나 삭제';

  @override
  String personaDeleteMessage(String name) {
    return '\"$name\"을(를) 삭제하시겠어요? 이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String get personaDeleteConfirm => '삭제';

  @override
  String get personaDeletedToast => '페르소나 삭제됨';

  @override
  String get personaCreatedToast => '페르소나 생성됨';

  @override
  String personaCreateFailedToast(String error) {
    return '페르소나 생성 실패: $error';
  }

  @override
  String get personaChangeAvatar => '아바타 변경';

  @override
  String get personaRemoveAvatar => '아바타 삭제';

  @override
  String get personaUploadAvatar => '아바타 업로드';

  @override
  String get personaTagsLabel => '페르소나 태그';

  @override
  String get personaTagPrefixLabel => '접두사';

  @override
  String get personaTagSuffixLabel => '접미사';

  @override
  String get personaVisibilityLabel => '공개 범위';

  @override
  String get personaVisibilityUnlisted => '일부 공개';

  @override
  String get personaVisibilityPublic => '공개';

  @override
  String get personaVisibilityPrivate => '비공개';

  @override
  String get personaNameRequired => '페르소나 표시 이름을 입력해 주세요';

  @override
  String get personaNameTooLong => '페르소나 표시 이름은 100자 이하여야 합니다';

  @override
  String get personaTagPrefixTooLong => '페르소나 태그 접두사는 32자 이하여야 합니다';

  @override
  String get personaTagSuffixTooLong => '페르소나 태그 접미사는 32자 이하여야 합니다';

  @override
  String personaTagCollisionError(String tag, String name) {
    return '\'$tag\' 태그는 이미 \'$name\'에서 사용 중입니다.';
  }

  @override
  String get chatInsertTimestamp => '타임스탬프 삽입';

  @override
  String get timestampPickerTitle => '타임스탬프 삽입';

  @override
  String get timestampPickerInsert => '삽입';

  @override
  String get timestampCopied => '타임스탬프가 복사되었습니다';

  @override
  String get timestampPickerTimeLabel => '시간';

  @override
  String get timestampPickerDateLabel => '날짜';

  @override
  String get timestampPickerTimeSectionLabel => '시간';

  @override
  String get timestampPickerTimezoneLabel => '시간대';

  @override
  String get timestampPickerFormatPreviewLabel => '형식 미리보기';

  @override
  String get timestampPickerNlpPlaceholder => '예: 내일 오후 3시, 2시간 후, 지금';

  @override
  String get timestampPickerSearchTimezones => '시간대 검색...';

  @override
  String get userProfileTimezoneSettingLabel => '시간대';

  @override
  String get userProfileTimezoneSettingDescription =>
      '프로필에 현지 시간을 표시하는 데 사용됩니다.';

  @override
  String get userProfileTimezoneNone => '없음';

  @override
  String get chatReactAs => '다른 프로필로 반응하기...';

  @override
  String get emojiCopy => '이모티콘 복사';

  @override
  String get emojiCopyLink => '링크 복사';

  @override
  String get personaSignatureEmojisLabel => '시그니처 이모지';

  @override
  String get personaSignatureEmojisDescription =>
      '시그니처 이모지로 반응하면 활성 페르소나와 관계없이 항상 이 페르소나로 반응합니다.';

  @override
  String get personaAddSignatureEmoji => '이모지 추가';

  @override
  String get personaSignatureEmojiAlreadyAdded => '이 이모지는 이미 시그니처 이모지로 추가되었습니다';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return '시그니처 이모지가 이미 \"$name\" 페르소나에서 사용 중입니다';
  }

  @override
  String get personaRemoveSignatureEmoji => '시그니처 이모지 삭제';
}
