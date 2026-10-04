// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class ForkLocalizationsTr extends ForkLocalizations {
  ForkLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Personayı değiştir';

  @override
  String get chatAttachmentPanelVoice => 'Sesli';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'Hızlı Geçiş düğmesi';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Daha hızlı gezinme için metin girişindeki sesli mesaj düğmesini Hızlı Geçiş ile değiştirin';

  @override
  String get userSettingsCheckForUpdates => 'Güncellemeleri kontrol et';

  @override
  String get userSettingsCheckingForUpdates =>
      'Güncellemeler kontrol ediliyor…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer güncel';

  @override
  String get userSettingsUpdateAvailableTitle => 'Güncelleme Mevcut';

  @override
  String get userSettingsUpdateDownloadAction => 'İndir ve Yükle';

  @override
  String get userSettingsUpdateInstallAction => 'Güncellemeyi Yükle';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Güncelleme indiriliyor (%$percent)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Güncelleme kontrol edilemedi veya indirilemedi.';

  @override
  String get personaSelectTitle => 'Persona Seç';

  @override
  String get personaSettingsHeader => 'Persona Ayarları';

  @override
  String get personaManageAction => 'Yönet';

  @override
  String get personaSearchPlaceholder =>
      'Personaları, etiketleri, zamirleri ara...';

  @override
  String get personaModeManual => 'Manuel';

  @override
  String get personaModeLast => 'Son kullanılan';

  @override
  String get personaModeManualDescription =>
      'Değiştirilene kadar her zaman seçilen persona olarak gönderir.';

  @override
  String get personaModeLastDescription =>
      'Son mesajınızda kullanılan personaya otomatik olarak geçer.';

  @override
  String get personaRecentHeader => 'SON PERSONALAR';

  @override
  String personaAllHeader(int count) {
    return 'TÜM PERSONALAR ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'ARAMA SONUÇLARI ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Kök hesap (Varsayılan)';

  @override
  String get personaEmptyState =>
      'Henüz yapılandırılmış persona yok. Personaları Yönet üzerinden bir tane oluşturun.';

  @override
  String get personaEmptySearch => 'Eşleşen persona bulunamadı.';

  @override
  String get personaEditTitle => 'Personayı Düzenle';

  @override
  String get personaCreateTitle => 'Persona Oluştur';

  @override
  String get personaDisplayNameLabel => 'Görünen Ad';

  @override
  String get personaPronounsLabel => 'Zamirler';

  @override
  String get personaPronounsHint => 'örn. o/onlar';

  @override
  String get personaBioHint => 'Diğerlerine bu personadan bahset...';

  @override
  String get personaUpdatedToast => 'Persona güncellendi';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Persona güncellenemedi: $error';
  }

  @override
  String get personaSectionTitle => 'Personalar';

  @override
  String get personaDisplayNameHint => 'Persona adı';

  @override
  String personaSendingAsTag(String name) {
    return '$name olarak gönderiliyor (Etiketle eşleşti)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return '$name olarak gönderiliyor (Kilitli)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return '@$username olarak gönderiliyor';
  }

  @override
  String get personaMainAccount => 'Ana hesap';

  @override
  String get personaEditPersona => 'Personayı düzenle';

  @override
  String get userSettingsNavPersonas => 'Personalar';

  @override
  String get personaSettingsDescription =>
      'Aktif persona modunuzu, özel görünen etiketinizi yapılandırın ve ayrı ayrı personaları yönetin.';

  @override
  String get personaDisplayTagSection => 'Görünen Etiket';

  @override
  String get personaDisplayTagDescription =>
      'Görünen etiket, mesajlardaki tüm persona adlarının yanında görünür. Eğer görünen etiket ayarlanmazsa hesap profil resminiz gösterilir.';

  @override
  String get personaDisplayTagLabel => 'Görünen Etiket Metni';

  @override
  String get personaDisplayTagHint => 'örn. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Görünen Etiket Simgesi';

  @override
  String get personaUploadTagIcon => 'Simge yükle';

  @override
  String get personaChangeTagIcon => 'Simgeyi değiştir';

  @override
  String get personaRemoveTagIcon => 'Simgeyi kaldır';

  @override
  String get personaChatPreviewTitle => 'Sohbet Önizlemesi';

  @override
  String get personaChatPreviewSampleMessage =>
      'Merhaba! Bu, görünen etiketiniz ve aktif personanızla mesajların nasıl görüneceğinin bir önizlemesidir.';

  @override
  String get personaListTitle => 'Yapılandırılmış Personalar';

  @override
  String get personaAddButton => 'Persona ekle';

  @override
  String get personaActiveBadge => 'Aktif';

  @override
  String get personaMakeActive => 'Aktif yap';

  @override
  String get personaDeleteTitle => 'Personayı Sil';

  @override
  String personaDeleteMessage(String name) {
    return '\"$name\" adlı personayı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get personaDeleteConfirm => 'Sil';

  @override
  String get personaDeletedToast => 'Persona silindi';

  @override
  String get personaCreatedToast => 'Persona oluşturuldu';

  @override
  String personaCreateFailedToast(String error) {
    return 'Persona oluşturulamadı: $error';
  }

  @override
  String get personaChangeAvatar => 'Avatarı Değiştir';

  @override
  String get personaRemoveAvatar => 'Avatarı Kaldır';

  @override
  String get personaUploadAvatar => 'Avatar Yükle';

  @override
  String get personaTagsLabel => 'Persona Etiketleri';

  @override
  String get personaTagPrefixLabel => 'Önek';

  @override
  String get personaTagSuffixLabel => 'Sonek';

  @override
  String get personaVisibilityLabel => 'Görünürlük';

  @override
  String get personaVisibilityUnlisted => 'Liste dışı';

  @override
  String get personaVisibilityPublic => 'Herkese açık';

  @override
  String get personaVisibilityPrivate => 'Gizli';

  @override
  String get personaNameRequired => 'Lütfen bir persona görünen adı girin';

  @override
  String get personaNameTooLong =>
      'Persona görünen adı en fazla 100 karakter olmalıdır';

  @override
  String get personaTagPrefixTooLong =>
      'Persona etiket öneki en fazla 32 karakter olmalıdır';

  @override
  String get personaTagSuffixTooLong =>
      'Persona etiket soneki en fazla 32 karakter olmalıdır';

  @override
  String personaTagCollisionError(String tag, String name) {
    return '\'$tag\' etiketi zaten \'$name\' tarafından kullanılıyor.';
  }

  @override
  String get chatInsertTimestamp => 'Zaman damgası ekle';

  @override
  String get timestampPickerTitle => 'Zaman damgası ekle';

  @override
  String get timestampPickerInsert => 'Ekle';

  @override
  String get timestampCopied => 'Zaman damgası kopyalandı';

  @override
  String get timestampPickerTimeLabel => 'Saat';

  @override
  String get timestampPickerDateLabel => 'TARİH';

  @override
  String get timestampPickerTimeSectionLabel => 'SAAT';

  @override
  String get timestampPickerTimezoneLabel => 'SAAT DİLİMİ';

  @override
  String get timestampPickerFormatPreviewLabel => 'BİÇİM ÖNİZLEMESİ';

  @override
  String get timestampPickerNlpPlaceholder =>
      'örn. yarın saat 15:00\'te, 2 saat sonra, şimdi';

  @override
  String get timestampPickerSearchTimezones => 'Saat dilimlerini ara...';

  @override
  String get userProfileTimezoneSettingLabel => 'Saat dilimi';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Profilinizde yerel saatinizi göstermek için kullanılır.';

  @override
  String get userProfileTimezoneNone => 'Yok';

  @override
  String get chatReactAs => 'Farklı bir profil olarak tepki ver...';

  @override
  String get emojiCopy => 'Emoji kopyala';

  @override
  String get emojiCopyLink => 'Bağlantıyı kopyala';

  @override
  String get personaSignatureEmojisLabel => 'İmza Emojileri';

  @override
  String get personaSignatureEmojisDescription =>
      'İmza emojisiyle tepki vermek, etkin personadan bağımsız olarak her zaman bu persona olarak tepki verir.';

  @override
  String get personaAddSignatureEmoji => 'Emoji Ekle';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Bu emoji zaten imza emojisi olarak eklenmiş';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'İmza emojisi zaten \"$name\" personası tarafından kullanılıyor';
  }

  @override
  String get personaRemoveSignatureEmoji => 'İmza emojisini kaldır';

  @override
  String get signalBarLabel => 'Sinyal Çubuğu';

  @override
  String get signalBarShow => 'Sinyal çubuğunu göster';

  @override
  String get signalBarHide => 'Sinyal çubuğunu gizle';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Bu sinyali açan kimse yok';

  @override
  String get signalBarReset => 'Sinyali herkes için sıfırla';

  @override
  String signalBarTurnOff(String name) {
    return '$name adına kapat';
  }
}
