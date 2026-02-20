AI Smart Glasses (Flutter)

คำอธิบาย
- แอพตัวอย่างสำหรับใช้งานกล้อง ถ่ายภาพ แล้วส่งไปวิเคราะห์ด้วย GenAI และอ่านข้อความด้วย TTS (ภาษาไทย)

ไฟล์สำคัญ
- lib/main.dart : UI และการจับภาพด้วยกล้อง
- lib/services/genai_service.dart : ตัวอย่างการอัปโหลดภาพไปยัง API ของ GenAI (ต้องแก้ endpoint/API key)
- lib/services/tts_service.dart : ห่อหุ้ม `flutter_tts` สำหรับการพูด

การตั้งค่า
1. ติดตั้ง Flutter SDK: https://flutter.dev
2. ในไฟล์ `lib/services/genai_service.dart` ให้แทนที่ `<YOUR_GOOGLE_API_KEY>` ด้วยคีย์ของคุณ และแก้ `uri` ให้เป็น endpoint จริงของ GenAI ที่ใช้งาน

เรียกใช้งาน
```bash
flutter pub get
flutter run
```

สิทธิ์ (Android/iOS)
- Android: แก้ `android/app/src/main/AndroidManifest.xml` เพื่อเพิ่มสิทธิ์ `CAMERA`, `RECORD_AUDIO`, `WRITE_EXTERNAL_STORAGE` ตามต้องการ
- iOS: แก้ `ios/Runner/Info.plist` เพื่อเพิ่ม `NSCameraUsageDescription`, `NSMicrophoneUsageDescription` เป็นต้น

หมายเหตุ
- โค้ดนี้เป็นสเกเลตันเพื่อเริ่มต้น: คุณอาจต้องปรับ `pubspec.yaml` เวอร์ชันแพ็กเกจให้ตรงกับ Flutter SDK ของคุณ และปรับ endpoint ของ GenAI ให้ถูกต้อง
- หากต้องการ preview แบบเรียลไทม์บน Android/iOS ต้องแน่ใจว่า plugin `camera` รองรับเวอร์ชัน Flutter ของคุณ
