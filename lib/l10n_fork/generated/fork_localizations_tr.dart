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
  String get personaSelectTitle => 'Persona Seç';

  @override
  String get personaSettingsHeader => 'Persona Ayarları';

  @override
  String get personaManageAction => 'Yönet';

  @override
  String get personaSearchPlaceholder =>
      'Personaları, etiketleri, zamirleri ara...';

  @override
  String get personaModeOff => 'Kapalı';

  @override
  String get personaModeManual => 'Manuel';

  @override
  String get personaModeLast => 'Son kullanılan';

  @override
  String get personaModeOffDescription =>
      'Persona etiketleri yazılmadıkça kök hesap olarak gönderir.';

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
  String get personaBioLabel => 'Biyografi / Hakkımda';

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
}
