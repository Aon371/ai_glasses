import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _tts = FlutterTts();

  TTSService() {
    _tts.setLanguage('th-TH');
    _tts.setSpeechRate(0.5);
    _tts.setVolume(1.0);
  }

  Future<void> speak(String text) async {
    final clean = _cleanText(text);
    if (clean.isEmpty) return;
    await _tts.speak(clean);
  }

  Future<void> tellDatetime() async {
    final now = DateTime.now();
    final thaiMonths = [
      'มกราคม','กุมภาพันธ์','มีนาคม','เมษายน','พฤษภาคม','มิถุนายน',
      'กรกฎาคม','สิงหาคม','กันยายน','ตุลาคม','พฤศจิกายน','ธันวาคม'
    ];
    final thaiYear = now.year + 543;
    final timeStr = 'ขณะนี้เวลา ${now.hour} นาฬิกา ${now.minute} นาที วันที่ ${now.day} ${thaiMonths[now.month-1]} พุทธศักราช $thaiYear ค่ะ';
    await speak(timeStr);
  }

  Future<void> tellHelp() async {
    final helpText = 'ปุ่ม สั้น สำรวจทาง, ปุ่ม ละเอียด ดูรายละเอียด, ปุ่ม อ่าน อ่านหนังสือ, ปุ่ม แปล แปลภาษา, ปุ่ม เวลา บอกวันเวลา, และปุ่ม ออก เพื่อปิดแอพ';
    await speak(helpText);
  }

  String _cleanText(String text) {
    return text.replaceAll(RegExp(r'[\*\#\-\_]'), '').replaceAll(RegExp(r'\n+'), ' ').trim();
  }

  void dispose() {
    _tts.stop();
  }
}
