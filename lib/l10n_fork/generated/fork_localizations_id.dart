// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class ForkLocalizationsId extends ForkLocalizations {
  ForkLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Ganti persona';

  @override
  String get chatAttachmentPanelVoice => 'Suara';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'Tombol Pengalih Cepat';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Ganti tombol pesan suara di kolom input dengan tombol Pengalih Cepat untuk navigasi cepat';

  @override
  String get userSettingsCheckForUpdates => 'Cek pembaruan';

  @override
  String get userSettingsCheckingForUpdates => 'Memeriksa pembaruan…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer sudah yang terbaru';

  @override
  String get userSettingsUpdateAvailableTitle => 'Pembaruan Tersedia';

  @override
  String get userSettingsUpdateDownloadAction => 'Unduh & Pasang';

  @override
  String get userSettingsUpdateInstallAction => 'Pasang Pembaruan';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Mengunduh pembaruan ($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Gagal memeriksa atau mengunduh pembaruan.';

  @override
  String get personaSelectTitle => 'Pilih Persona';

  @override
  String get personaSettingsHeader => 'Pengaturan Persona';

  @override
  String get personaManageAction => 'Kelola';

  @override
  String get personaSearchPlaceholder => 'Cari persona, tag, kata ganti...';

  @override
  String get personaModeManual => 'Manual';

  @override
  String get personaModeLast => 'Terakhir Digunakan';

  @override
  String get personaModeManualDescription =>
      'Selalu mengirim sebagai persona yang dipilih sampai diubah.';

  @override
  String get personaModeLastDescription =>
      'Beralih otomatis ke persona yang digunakan dalam pesan terakhir Anda.';

  @override
  String get personaRecentHeader => 'PERSONA TERBARU';

  @override
  String personaAllHeader(int count) {
    return 'SEMUA PERSONA ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'HASIL PENCARIAN ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Akun Utama (Default)';

  @override
  String get personaEmptyState =>
      'Belum ada persona yang dikonfigurasi. Buat melalui Kelola Persona.';

  @override
  String get personaEmptySearch => 'Tidak ditemukan persona yang cocok.';

  @override
  String get personaEditTitle => 'Edit Persona';

  @override
  String get personaCreateTitle => 'Buat Persona';

  @override
  String get personaDisplayNameLabel => 'Nama Tampilan';

  @override
  String get personaPronounsLabel => 'Kata ganti';

  @override
  String get personaPronounsHint => 'mis. they/them';

  @override
  String get personaBioHint =>
      'Ceritakan tentang persona ini kepada yang lain...';

  @override
  String get personaUpdatedToast => 'Persona diperbarui';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Gagal memperbarui persona: $error';
  }

  @override
  String get personaSectionTitle => 'Persona';

  @override
  String get personaDisplayNameHint => 'Nama persona';

  @override
  String personaSendingAsTag(String name) {
    return 'Mengirim sebagai $name (Cocok dengan tag)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Mengirim sebagai $name (Terkunci)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Mengirim sebagai @$username';
  }

  @override
  String get personaMainAccount => 'Akun utama';

  @override
  String get personaEditPersona => 'Edit persona';

  @override
  String get userSettingsNavPersonas => 'Persona';

  @override
  String get personaSettingsDescription =>
      'Konfigurasikan mode persona aktif, tag tampilan kustom, dan kelola persona masing-masing.';

  @override
  String get personaDisplayTagSection => 'Tag Tampilan';

  @override
  String get personaDisplayTagDescription =>
      'Tag tampilan akan muncul di sebelah semua nama persona dalam pesan. Jika tag tampilan tidak diatur, foto profil akun Anda akan ditampilkan.';

  @override
  String get personaDisplayTagLabel => 'Teks Tag Tampilan';

  @override
  String get personaDisplayTagHint => 'mis. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Ikon Tag Tampilan';

  @override
  String get personaUploadTagIcon => 'Unggah ikon';

  @override
  String get personaChangeTagIcon => 'Ubah ikon';

  @override
  String get personaRemoveTagIcon => 'Hapus ikon';

  @override
  String get personaChatPreviewTitle => 'Pratinjau Obrolan';

  @override
  String get personaChatPreviewSampleMessage =>
      'Halo! Ini adalah pratinjau tampilan pesan dengan tag tampilan dan persona aktif Anda.';

  @override
  String get personaListTitle => 'Persona Terkonfigurasi';

  @override
  String get personaAddButton => 'Tambah Persona';

  @override
  String get personaActiveBadge => 'Aktif';

  @override
  String get personaMakeActive => 'Jadikan Aktif';

  @override
  String get personaDeleteTitle => 'Hapus Persona';

  @override
  String personaDeleteMessage(String name) {
    return 'Apakah Anda yakin ingin menghapus \"$name\"? Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get personaDeleteConfirm => 'Hapus';

  @override
  String get personaDeletedToast => 'Persona dihapus';

  @override
  String get personaCreatedToast => 'Persona dibuat';

  @override
  String personaCreateFailedToast(String error) {
    return 'Gagal membuat persona: $error';
  }

  @override
  String get personaChangeAvatar => 'Ganti avatar';

  @override
  String get personaRemoveAvatar => 'Hapus avatar';

  @override
  String get personaUploadAvatar => 'Unggah avatar';

  @override
  String get personaTagsLabel => 'Tag Persona';

  @override
  String get personaTagPrefixLabel => 'Awalan';

  @override
  String get personaTagSuffixLabel => 'Akhiran';

  @override
  String get personaVisibilityLabel => 'Visibilitas';

  @override
  String get personaVisibilityUnlisted => 'Tidak terdaftar';

  @override
  String get personaVisibilityPublic => 'Publik';

  @override
  String get personaVisibilityPrivate => 'Privat';

  @override
  String get personaNameRequired => 'Silakan masukkan nama tampilan persona';

  @override
  String get personaNameTooLong =>
      'Nama tampilan persona harus 100 karakter atau kurang';

  @override
  String get personaTagPrefixTooLong =>
      'Awalan tag persona harus 32 karakter atau kurang';

  @override
  String get personaTagSuffixTooLong =>
      'Akhiran tag persona harus 32 karakter atau kurang';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Tag \'$tag\' sudah digunakan oleh \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Sisipkan stempel waktu';

  @override
  String get timestampPickerTitle => 'Sisipkan stempel waktu';

  @override
  String get timestampPickerInsert => 'Sisipkan';

  @override
  String get timestampCopied => 'Stempel waktu disalin';

  @override
  String get timestampPickerTimeLabel => 'Waktu';

  @override
  String get timestampPickerDateLabel => 'TANGGAL';

  @override
  String get timestampPickerTimeSectionLabel => 'WAKTU';

  @override
  String get timestampPickerTimezoneLabel => 'ZONA WAKTU';

  @override
  String get timestampPickerFormatPreviewLabel => 'PRATINJAU FORMAT';

  @override
  String get timestampPickerNlpPlaceholder =>
      'mis. besok jam 3 sore, dalam 2 jam, sekarang';

  @override
  String get timestampPickerSearchTimezones => 'Cari zona waktu...';

  @override
  String get userProfileTimezoneSettingLabel => 'Zona waktu';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Digunakan untuk menampilkan waktu lokal di profil Anda.';

  @override
  String get userProfileTimezoneNone => 'Tidak ada';

  @override
  String get chatReactAs => 'Bereaksi sebagai...';

  @override
  String get emojiCopy => 'Salin emoji';

  @override
  String get emojiCopyLink => 'Salin tautan';

  @override
  String get personaSignatureEmojisLabel => 'Emoji Tanda Tangan';

  @override
  String get personaSignatureEmojisDescription =>
      'Bereaksi dengan emoji tanda tangan akan selalu bereaksi sebagai persona ini, terlepas dari persona yang aktif.';

  @override
  String get personaAddSignatureEmoji => 'Tambah Emoji';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Emoji ini sudah ditambahkan sebagai emoji tanda tangan';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'Emoji tanda tangan sudah digunakan oleh persona \"$name\"';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Hapus emoji tanda tangan';
}
