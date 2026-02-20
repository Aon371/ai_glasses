import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'services/genai_service.dart';
import 'services/tts_service.dart';

late final List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Smart Glasses',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraController? _controller;
  bool _isProcessing = false;

  final _genai = GenAIService();
  final _tts = TTSService();

  @override
  void initState() {
    super.initState();
    _initCamera();
    _printStartupInfo();
  }

  void _printStartupInfo() {
    print('--- AI Smart Glasses ---');
    print('[สั้น] = อธิบายภาพแบบสั้นๆ');
    print('[ละเอียด] = อธิบายภาพแบบละเอียด');
    print('[อ่าน] = อ่านหนังสือ/ข้อความในภาพ');
    print('[ป้าย] = อ่านป้ายแสดงข้อความ');
    print('[เวลา] = บอกเวลาปัจจุบัน');
    print('[ถาม] = ถามคำถามอิสระเกี่ยวกับภาพ');
    print('[ออก] = ปิดแอปพลิเคชัน');
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller?.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _captureAndAnalyze(String mode) async {
    if (_controller == null || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final xfile = await _controller!.takePicture();
      final file = File(xfile.path);
      final result = await _genai.analyzeImage(file, mode);
      await _tts.speak(result);
    } catch (e) {
      await _tts.speak('เกิดข้อผิดพลาด');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _askQuestion() async {
    if (_controller == null || _isProcessing) return;
    
    final TextEditingController questionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ถามคำถาม'),
        content: TextField(
          controller: questionController,
          decoration: const InputDecoration(hintText: 'พิมพ์คำถาม...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final question = questionController.text.trim();
              if (question.isEmpty) return;
              
              setState(() => _isProcessing = true);
              try {
                final xfile = await _controller!.takePicture();
                final file = File(xfile.path);
                final result = await _genai.askQuestion(file, question);
                await _tts.speak(result);
              } catch (e) {
                await _tts.speak('เกิดข้อผิดพลาด');
              } finally {
                if (mounted) setState(() => _isProcessing = false);
              }
            },
            child: const Text('ถาม'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Smart Glasses')),
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CameraPreview(_controller!),
                Positioned(
                  bottom: 16,
                  left: 8,
                  right: 8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(onPressed: _isProcessing ? null : () => _captureAndAnalyze('short'), child: const Text('สั้น')),
                          ElevatedButton(onPressed: _isProcessing ? null : () => _captureAndAnalyze('detail'), child: const Text('ละเอียด')),
                          ElevatedButton(onPressed: _isProcessing ? null : () => _captureAndAnalyze('read'), child: const Text('อ่าน')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(onPressed: _isProcessing ? null : () => _captureAndAnalyze('sign'), child: const Text('ป้าย')),
                          ElevatedButton(onPressed: _isProcessing ? null : () async => await _tts.tellDatetime(), child: const Text('เวลา')),
                          ElevatedButton(onPressed: _isProcessing ? null : () => _askQuestion(), child: const Text('ถาม')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: () => exit(0), child: const Text('ออก')),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
