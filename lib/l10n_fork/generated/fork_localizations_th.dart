// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class ForkLocalizationsTh extends ForkLocalizations {
  ForkLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get chatMessageChangePersona => 'เปลี่ยน Persona';

  @override
  String get advancedSettingQuickSwitcherButtonLabel => 'ปุ่มตัวสลับด่วน';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'แทนที่ปุ่มข้อความเสียงในช่องพิมพ์ด้วยปุ่มตัวสลับด่วนเพื่อการนำทางที่รวดเร็ว';

  @override
  String get personaSelectTitle => 'เลือก Persona';

  @override
  String get personaSettingsHeader => 'การตั้งค่า Persona';

  @override
  String get personaManageAction => 'จัดการ';

  @override
  String get personaSearchPlaceholder => 'ค้นหา Persona, แท็ก, คำสรรพนาม...';

  @override
  String get personaModeOff => 'ปิด';

  @override
  String get personaModeManual => 'ดำเนินการเอง';

  @override
  String get personaModeLast => 'ใช้งานล่าสุด';

  @override
  String get personaModeOffDescription =>
      'ส่งในชื่อบัญชีหลัก เว้นแต่จะพิมพ์แท็ก Persona';

  @override
  String get personaModeManualDescription =>
      'ส่งในชื่อ Persona ที่เลือกไว้เสมอจนกว่าจะมีการเปลี่ยนแปลง';

  @override
  String get personaModeLastDescription =>
      'สลับไปยัง Persona ที่ใช้ในข้อความล่าสุดของคุณโดยอัตโนมัติ';

  @override
  String get personaRecentHeader => 'PERSONA ล่าสุด';

  @override
  String personaAllHeader(int count) {
    return 'PERSONA ทั้งหมด ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'ผลการค้นหา ($count)';
  }

  @override
  String get personaRootAccountLabel => 'บัญชีหลัก (ค่าเริ่มต้น)';

  @override
  String get personaEmptyState =>
      'ยังไม่ได้ตั้งค่า Persona สร้างได้ผ่านจัดการ Persona';

  @override
  String get personaEmptySearch => 'ไม่พบ Persona ที่ตรงกัน';

  @override
  String get personaEditTitle => 'แก้ไข Persona';

  @override
  String get personaCreateTitle => 'สร้าง Persona';

  @override
  String get personaDisplayNameLabel => 'ชื่อที่แสดง';

  @override
  String get personaPronounsLabel => 'คำสรรพนาม';

  @override
  String get personaPronounsHint => 'เช่น they/them';

  @override
  String get personaBioLabel => 'ประวัติส่วนตัว / เกี่ยวกับฉัน';

  @override
  String get personaBioHint => 'บอกเล่าเกี่ยวกับ Persona นี้ให้ผู้อื่นรู้...';

  @override
  String get personaUpdatedToast => 'อัปเดต Persona แล้ว';

  @override
  String personaUpdateFailedToast(String error) {
    return 'อัปเดต Persona ไม่สำเร็จ: $error';
  }

  @override
  String get personaSectionTitle => 'Persona';

  @override
  String get personaDisplayNameHint => 'ชื่อ Persona';

  @override
  String personaSendingAsTag(String name) {
    return 'กำลังส่งในชื่อ $name (ตรงกับแท็ก)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'กำลังส่งในชื่อ $name (ล็อคแล้ว)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'กำลังส่งในชื่อ @$username';
  }

  @override
  String get personaMainAccount => 'บัญชีหลัก';

  @override
  String get personaEditPersona => 'แก้ไข Persona';

  @override
  String get userSettingsNavPersonas => 'Persona';

  @override
  String get personaSettingsDescription =>
      'กำหนดค่าโหมด Persona ที่ใช้งานอยู่ แท็กแสดงผลแบบกำหนดเอง และจัดการแต่ละ Persona';

  @override
  String get personaDisplayTagSection => 'แท็กแสดงผล';

  @override
  String get personaDisplayTagDescription =>
      'แท็กแสดงผลจะปรากฏถัดจากชื่อ Persona ทั้งหมดในข้อความ หากไม่ได้ตั้งค่าแท็กแสดงผล จะแสดงรูปโปรไฟล์บัญชีของคุณแทน';

  @override
  String get personaDisplayTagLabel => 'ข้อความแท็กแสดงผล';

  @override
  String get personaDisplayTagHint => 'เช่น SYS';

  @override
  String get personaDisplayTagIconLabel => 'ไอคอนแท็กแสดงผล';

  @override
  String get personaUploadTagIcon => 'อัปโหลดไอคอน';

  @override
  String get personaChangeTagIcon => 'เปลี่ยนไอคอน';

  @override
  String get personaRemoveTagIcon => 'ลบไอคอน';

  @override
  String get personaChatPreviewTitle => 'ตัวอย่างแชท';

  @override
  String get personaChatPreviewSampleMessage =>
      'สวัสดี! นี่คือตัวอย่างลักษณะข้อความที่แสดงพร้อมแท็กแสดงผลและ Persona ที่ใช้งานอยู่ของคุณ';

  @override
  String get personaListTitle => 'Persona ที่ตั้งค่าไว้';

  @override
  String get personaAddButton => 'เพิ่ม Persona';

  @override
  String get personaActiveBadge => 'ใช้งานอยู่';

  @override
  String get personaMakeActive => 'ตั้งเป็นใช้งานอยู่';

  @override
  String get personaDeleteTitle => 'ลบ Persona';

  @override
  String personaDeleteMessage(String name) {
    return 'คุณแน่ใจหรือไม่ว่าต้องการลบ \"$name\"? การดำเนินการนี้ไม่สามารถย้อนกลับได้';
  }

  @override
  String get personaDeleteConfirm => 'ลบ';

  @override
  String get personaDeletedToast => 'ลบ Persona แล้ว';

  @override
  String get personaCreatedToast => 'สร้าง Persona แล้ว';

  @override
  String personaCreateFailedToast(String error) {
    return 'สร้าง Persona ไม่สำเร็จ: $error';
  }

  @override
  String get personaChangeAvatar => 'เปลี่ยนรูปโปรไฟล์';

  @override
  String get personaRemoveAvatar => 'ลบรูปโปรไฟล์';

  @override
  String get personaUploadAvatar => 'อัปโหลดรูปโปรไฟล์';

  @override
  String get personaTagsLabel => 'แท็ก Persona';

  @override
  String get personaTagPrefixLabel => 'คำนำหน้า';

  @override
  String get personaTagSuffixLabel => 'คำต่อท้าย';

  @override
  String get personaVisibilityLabel => 'การมองเห็น';

  @override
  String get personaVisibilityUnlisted => 'ไม่แสดงในรายการ';

  @override
  String get personaVisibilityPublic => 'สาธารณะ';

  @override
  String get personaVisibilityPrivate => 'ส่วนตัว';

  @override
  String get personaNameRequired => 'โปรดป้อนชื่อที่แสดงของ Persona';

  @override
  String get personaNameTooLong =>
      'ชื่อที่แสดงของ Persona ต้องมีความยาวไม่เกิน 100 ตัวอักษร';

  @override
  String get personaTagPrefixTooLong =>
      'คำนำหน้าแท็ก Persona ต้องมีความยาวไม่เกิน 32 ตัวอักษร';

  @override
  String get personaTagSuffixTooLong =>
      'คำต่อท้ายแท็ก Persona ต้องมีความยาวไม่เกิน 32 ตัวอักษร';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'แท็ก \'$tag\' ถูกใช้งานโดย \'$name\' แล้ว';
  }
}
