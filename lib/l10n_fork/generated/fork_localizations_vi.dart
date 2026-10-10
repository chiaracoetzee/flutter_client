// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class ForkLocalizationsVi extends ForkLocalizations {
  ForkLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Đổi persona';

  @override
  String get chatAttachmentPanelVoice => 'Thoại';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'Nút chuyển nhanh';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Thay thế nút tin nhắn thoại trong khung soạn thảo bằng nút chuyển nhanh để điều hướng thuận tiện';

  @override
  String get userSettingsCheckForUpdates => 'Kiểm tra cập nhật';

  @override
  String get userSettingsCheckingForUpdates => 'Đang kiểm tra cập nhật…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer đã được cập nhật';

  @override
  String get userSettingsUpdateAvailableTitle => 'Có bản cập nhật mới';

  @override
  String get userSettingsUpdateDownloadAction => 'Tải về và cài đặt';

  @override
  String get userSettingsUpdateInstallAction => 'Cài đặt bản cập nhật';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Đang tải bản cập nhật ($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Không thể kiểm tra hoặc tải xuống bản cập nhật.';

  @override
  String get personaSelectTitle => 'Chọn persona';

  @override
  String get personaSettingsHeader => 'Cài đặt persona';

  @override
  String get personaManageAction => 'Quản lý';

  @override
  String get personaSearchPlaceholder => 'Tìm kiếm persona, thẻ, đại từ...';

  @override
  String get personaModeManual => 'Thủ công';

  @override
  String get personaModeLast => 'Sử dụng lần cuối';

  @override
  String get personaModeManualDescription =>
      'Luôn gửi dưới dạng persona đã chọn cho đến khi thay đổi.';

  @override
  String get personaModeLastDescription =>
      'Tự động chuyển sang persona được sử dụng trong tin nhắn gần nhất của bạn.';

  @override
  String get personaRecentHeader => 'PERSONA GẦN ĐÂY';

  @override
  String personaAllHeader(int count) {
    return 'TẤT CẢ PERSONA ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'KẾT QUẢ TÌM KIẾM ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Tài khoản gốc (Mặc định)';

  @override
  String get personaEmptyState =>
      'Chưa cấu hình persona nào. Hãy tạo một persona qua Quản lý persona.';

  @override
  String get personaEmptySearch => 'Không tìm thấy persona nào phù hợp.';

  @override
  String get personaEditTitle => 'Chỉnh sửa persona';

  @override
  String get personaCreateTitle => 'Tạo persona';

  @override
  String get personaDisplayNameLabel => 'Tên hiển thị';

  @override
  String get personaPronounsLabel => 'Đại từ nhân xưng';

  @override
  String get personaPronounsHint => 'vd. they/them';

  @override
  String get personaBioHint => 'Giới thiệu với người khác về persona này...';

  @override
  String get personaUpdatedToast => 'Đã cập nhật persona';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Không thể cập nhật persona: $error';
  }

  @override
  String get personaSectionTitle => 'Persona';

  @override
  String get personaDisplayNameHint => 'Tên persona';

  @override
  String personaSendingAsTag(String name) {
    return 'Đang gửi dưới dạng $name (Khớp theo thẻ)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Đang gửi dưới dạng $name (Đã khóa)';
  }

  @override
  String personaSendingAs(String name) {
    return 'Đang gửi dưới dạng $name';
  }

  @override
  String personaPostingAs(String name) {
    return 'Đang đăng dưới dạng $name';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Đang gửi dưới dạng @$username';
  }

  @override
  String get personaMainAccount => 'Tài khoản chính';

  @override
  String get personaEditPersona => 'Chỉnh sửa persona';

  @override
  String get userSettingsNavPersonas => 'Persona';

  @override
  String get personaSettingsDescription =>
      'Cấu hình chế độ persona đang hoạt động, thẻ hiển thị tùy chỉnh và quản lý các persona riêng lẻ.';

  @override
  String get personaDisplayTagSection => 'Thẻ hiển thị';

  @override
  String get personaDisplayTagDescription =>
      'Thẻ hiển thị sẽ xuất hiện cạnh tất cả tên persona trong tin nhắn. Nếu không có thẻ hiển thị, ảnh đại diện tài khoản của bạn sẽ được hiển thị.';

  @override
  String get personaDisplayTagLabel => 'Văn bản thẻ hiển thị';

  @override
  String get personaDisplayTagHint => 'vd. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Biểu tượng thẻ hiển thị';

  @override
  String get personaUploadTagIcon => 'Tải biểu tượng lên';

  @override
  String get personaChangeTagIcon => 'Đổi biểu tượng';

  @override
  String get personaRemoveTagIcon => 'Xóa biểu tượng';

  @override
  String get personaChatPreviewTitle => 'Xem trước đoạn chat';

  @override
  String get personaChatPreviewSampleMessage =>
      'Xin chào! Đây là bản xem trước cách tin nhắn xuất hiện cùng thẻ hiển thị và persona đang hoạt động của bạn.';

  @override
  String get personaListTitle => 'Persona đã cấu hình';

  @override
  String get personaAddButton => 'Thêm persona';

  @override
  String get personaActiveBadge => 'Đang hoạt động';

  @override
  String get personaMakeActive => 'Đặt làm hoạt động';

  @override
  String get personaDeleteTitle => 'Xóa persona';

  @override
  String personaDeleteMessage(String name) {
    return 'Bạn có chắc chắn muốn xóa \"$name\" không? Hành động này không thể hoàn tác.';
  }

  @override
  String get personaDeleteConfirm => 'Xóa';

  @override
  String get personaDeletedToast => 'Đã xóa persona';

  @override
  String get personaCreatedToast => 'Đã tạo persona';

  @override
  String personaCreateFailedToast(String error) {
    return 'Không thể tạo persona: $error';
  }

  @override
  String get personaChangeAvatar => 'Đổi ảnh đại diện';

  @override
  String get personaRemoveAvatar => 'Xóa ảnh đại diện';

  @override
  String get personaUploadAvatar => 'Tải ảnh đại diện lên';

  @override
  String get personaTagsLabel => 'Thẻ persona';

  @override
  String get personaTagPrefixLabel => 'Tiền tố';

  @override
  String get personaTagSuffixLabel => 'Hậu tố';

  @override
  String get personaVisibilityLabel => 'Chế độ hiển thị';

  @override
  String get personaVisibilityUnlisted => 'Không được liệt kê';

  @override
  String get personaVisibilityPublic => 'Công khai';

  @override
  String get personaVisibilityPrivate => 'Riêng tư';

  @override
  String get personaNameRequired => 'Vui lòng nhập tên hiển thị cho persona';

  @override
  String get personaNameTooLong =>
      'Tên hiển thị của persona phải có từ 100 ký tự trở xuống';

  @override
  String get personaTagPrefixTooLong =>
      'Tiền tố thẻ persona phải có từ 32 ký tự trở xuống';

  @override
  String get personaTagSuffixTooLong =>
      'Hậu tố thẻ persona phải có từ 32 ký tự trở xuống';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Thẻ \'$tag\' đã được \'$name\' sử dụng.';
  }

  @override
  String get chatInsertTimestamp => 'Chèn dấu thời gian';

  @override
  String get chatAttachmentSendVoiceMessage => 'Gửi tin nhắn thoại';

  @override
  String get timestampPickerTitle => 'Chèn dấu thời gian';

  @override
  String get timestampPickerInsert => 'Chèn';

  @override
  String get timestampCopied => 'Đã sao chép dấu thời gian';

  @override
  String get timestampPickerTimeLabel => 'Thời gian';

  @override
  String get timestampPickerDateLabel => 'NGÀY';

  @override
  String get timestampPickerTimeSectionLabel => 'GIỜ';

  @override
  String get timestampPickerTimezoneLabel => 'MÚI GIỜ';

  @override
  String get timestampPickerFormatPreviewLabel => 'XEM TRƯỚC ĐỊNH DẠNG';

  @override
  String get timestampPickerNlpPlaceholder =>
      'ví dụ: ngày mai lúc 3 giờ chiều, trong 2 giờ nữa, bây giờ';

  @override
  String get timestampPickerSearchTimezones => 'Tìm kiếm múi giờ...';

  @override
  String get userProfileTimezoneSettingLabel => 'Múi giờ';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Được sử dụng để hiển thị giờ địa phương trên hồ sơ của bạn.';

  @override
  String get userProfileTimezoneNone => 'Không có';

  @override
  String get chatReactAs => 'Thả cảm xúc dưới tên...';

  @override
  String get emojiCopy => 'Sao chép biểu tượng cảm xúc';

  @override
  String get emojiCopyLink => 'Sao chép liên kết';

  @override
  String get personaSignatureEmojisLabel => 'Biểu tượng cảm xúc đặc trưng';

  @override
  String get personaSignatureEmojisDescription =>
      'Bày tỏ cảm xúc bằng biểu tượng đặc trưng sẽ luôn phản hồi dưới tư cách nhân cách này, bất kể nhân cách đang hoạt động là gì.';

  @override
  String get personaAddSignatureEmoji => 'Thêm biểu tượng cảm xúc';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Biểu tượng cảm xúc này đã được thêm làm biểu tượng đặc trưng';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Biểu tượng cảm xúc đặc trưng đã được nhân cách \"$name\" sử dụng';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Xóa biểu tượng cảm xúc đặc trưng';

  @override
  String get signalBarLabel => 'Thanh tín hiệu';

  @override
  String get signalBarShow => 'Hiện thanh tín hiệu';

  @override
  String get signalBarHide => 'Ẩn thanh tín hiệu';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Chưa ai bật tín hiệu này';

  @override
  String get signalBarReset => 'Đặt lại tín hiệu cho mọi người';

  @override
  String signalBarTurnOff(String name) {
    return 'Tắt $name';
  }

  @override
  String instanceUrlHelperDefault(String domain) {
    return 'Dùng $domain cho máy chủ mặc định, hoặc URL chính xác của một máy chủ khác.';
  }

  @override
  String get instanceResetToDefault => 'Đặt lại về máy chủ mặc định';
}
