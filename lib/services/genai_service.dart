import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'config.dart';

class GenAIService {
  final String apiKey = Config.apiKey;
  final String modelName = Config.modelName;

  Future<String> analyzeImage(File imageFile, String mode) async {
    final bytes = await imageFile.readAsBytes();
    return await analyzeImageBytes(bytes, mode);
  }

  Future<String> analyzeImageBytes(Uint8List bytes, String mode) async {
    final instruction = _instructionForMode(mode);
    final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta2/models/$modelName:generateContent?key=$apiKey');
    final b64 = base64Encode(bytes);

    final body = {
      'contents': [
        {
          'parts': [
            {'text': instruction},
            {
              'inlineData': {
                'mimeType': 'image/jpeg',
                'data': b64
              }
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is Map && json.containsKey('candidates')) {
          final candidates = json['candidates'] as List;
          if (candidates.isNotEmpty) {
            final content = candidates[0]['content'];
            if (content is Map && content.containsKey('parts')) {
              final parts = content['parts'] as List;
              if (parts.isNotEmpty && parts[0] is Map && parts[0].containsKey('text')) {
                return parts[0]['text'];
              }
            }
          }
        }
        print('[GenAI] Unexpected success response structure: ${response.body}');
        return 'ไม่สามารถวิเคราะห์ได้ (รูปแบบผลลัพธ์ไม่คาดคิด)';
      } else {
        print('[GenAI] HTTP ${response.statusCode}: ${response.body}');
        return 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์ AI (สถานะ ${response.statusCode})';
      }
    } catch (e, st) {
      print('[GenAI] Exception: $e\n$st');
      return 'เกิดข้อผิดพลาดขณะเชื่อมต่อกับ AI: ${e.toString()}';
    }
  }

  Future<String> askQuestion(File imageFile, String question) async {
    final bytes = await imageFile.readAsBytes();
    return await askQuestionBytes(bytes, question);
  }

  Future<String> askQuestionBytes(Uint8List bytes, String question) async {
    final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta2/models/$modelName:generateContent?key=$apiKey');
    final b64 = base64Encode(bytes);

    final body = {
      'contents': [
        {
          'parts': [
            {'text': question},
            {
              'inlineData': {
                'mimeType': 'image/jpeg',
                'data': b64
              }
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is Map && json.containsKey('candidates')) {
          final candidates = json['candidates'] as List;
          if (candidates.isNotEmpty) {
            final content = candidates[0]['content'];
            if (content is Map && content.containsKey('parts')) {
              final parts = content['parts'] as List;
              if (parts.isNotEmpty && parts[0] is Map && parts[0].containsKey('text')) {
                return parts[0]['text'];
              }
            }
          }
        }
        print('[GenAI] Unexpected question response structure: ${response.body}');
        return 'ไม่สามารถตอบได้ (รูปแบบผลลัพธ์ไม่คาดคิด)';
      } else {
        print('[GenAI] HTTP ${response.statusCode}: ${response.body}');
        return 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์ AI (สถานะ ${response.statusCode})';
      }
    } catch (e, st) {
      print('[GenAI] Exception: $e\n$st');
      return 'เกิดข้อผิดพลาดขณะเชื่อมต่อกับ AI: ${e.toString()}';
    }
  }

  String _instructionForMode(String mode) {
    switch (mode) {
      case 'short':
        return 'บรรยายภาพนี้สั้นๆ ไม่เกิน 1-2 ประโยค บอกแค่ว่ามีวัตถุอะไรหลักๆ หรือสิ่งกีดขวางอะไร ห้ามใช้ Markdown';
      case 'detail':
        return 'บรรยายภาพนี้อย่างละเอียด บอกลักษณะสิ่งของ สี รูปร่าง และสภาพแวดล้อม ห้ามใช้ Markdown';
      case 'read':
        return 'อ่านข้อความทั้งหมดที่เห็นในภาพตามตัวอักษรจริงเป๊ะๆ ไม่ต้องแปล ห้ามบรรยายรูปภาพ อ่านเฉพาะข้อความเท่านั้น';
      case 'sign':
        return 'แสกนหา ค้นหา และบอกข้อความจากป้ายทั้งหมดในภาพนี้ อ่านเฉพาะข้อความบนป้าย ห้ามบรรยายภาพอื่นๆ';
      case 'translate':
        return 'แปลข้อความทั้งหมดในภาพให้เป็นภาษาไทย แล้วอ่านคำแปลออกมา ห้ามบรรยายรูปภาพ';
      default:
        return 'บรรยายภาพนี้';
    }
  }
}
