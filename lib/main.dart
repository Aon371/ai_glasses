import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

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
  String? _lastHoverLabel;
  DateTime? _lastHoverAt;

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
      print('[Action] Capturing image for mode: $mode');
      final xfile = await _controller!.takePicture();
      Uint8List bytes;
      if (kIsWeb) {
        bytes = await xfile.readAsBytes();
      } else {
        final file = File(xfile.path);
        bytes = await file.readAsBytes();
      }
      print('[Action] Sending image to GenAI (mode=$mode)');
      final result = await _genai.analyzeImageBytes(bytes, mode);
      print('[Action] Received result for mode=$mode: $result');
      // allow UI/buttons to be used again while TTS speaks
      if (mounted) setState(() => _isProcessing = false);
      await _tts.speak(result);
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
      print('[Action] Error during capture/analyze: $e');
      await _tts.speak('เกิดข้อผิดพลาด');
    }
  }

  void _handleHover(String label) {
    final now = DateTime.now();
    if (_lastHoverLabel == label && _lastHoverAt != null && now.difference(_lastHoverAt!).inSeconds < 2) return;
    _lastHoverLabel = label;
    _lastHoverAt = now;
    _tts.speak(label);
  }

  Future<void> _askQuestion() async {
    if (_controller == null || _isProcessing) return;

    setState(() => _isProcessing = true);
    XFile? xfile;
    try {
      xfile = await _controller!.takePicture();
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
      await _tts.speak('ไม่สามารถถ่ายภาพสำหรับถามได้');
      return;
    }

    Uint8List bytes;
    if (kIsWeb) {
      bytes = await xfile.readAsBytes();
    } else {
      final imageFile = File(xfile.path);
      bytes = await imageFile.readAsBytes();
    }
    if (mounted) setState(() => _isProcessing = false);

    final TextEditingController questionController = TextEditingController();
    final List<String> history = [];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('ถามคำถาม (สนทนา)') ,
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: history.length,
                      itemBuilder: (context, idx) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(history[idx]),
                      ),
                    ),
                  ),
                  TextField(
                    controller: questionController,
                    decoration: const InputDecoration(hintText: 'พิมพ์คำถาม...'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ปิด'),
              ),
                  TextButton(
                    onPressed: () async {
                      final question = questionController.text.trim();
                      if (question.isEmpty) return;
                      questionController.clear();
                      // show a temporary entry
                      setStateDialog(() => history.add('คุณ: $question'));
                      try {
                        if (mounted) setState(() => _isProcessing = true);
                        final result = await _genai.askQuestionBytes(bytes, question);
                        setStateDialog(() => history.add('AI: $result'));
                        if (mounted) setState(() => _isProcessing = false);
                        await _tts.speak(result);
                      } catch (e) {
                        if (mounted) setState(() => _isProcessing = false);
                        setStateDialog(() => history.add('AI: เกิดข้อผิดพลาด'));
                        await _tts.speak('เกิดข้อผิดพลาดขณะถาม');
                      }
                    },
                    child: const Text('ถาม'),
                  ),
            ],
          );
        });
      },
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
                          MouseRegion(
                            onEnter: (_) => _handleHover('สั้น'),
                            child: ElevatedButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () async {
                                      print('[UI] Button pressed: short');
                                      await _captureAndAnalyze('short');
                                    },
                              child: const Text('สั้น'),
                            ),
                          ),
                          MouseRegion(
                            onEnter: (_) => _handleHover('ละเอียด'),
                            child: ElevatedButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () async {
                                      print('[UI] Button pressed: detail');
                                      await _captureAndAnalyze('detail');
                                    },
                              child: const Text('ละเอียด'),
                            ),
                          ),
                          MouseRegion(
                            onEnter: (_) => _handleHover('อ่าน'),
                            child: ElevatedButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () async {
                                      print('[UI] Button pressed: read');
                                      await _captureAndAnalyze('read');
                                    },
                              child: const Text('อ่าน'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MouseRegion(
                            onEnter: (_) => _handleHover('ป้าย'),
                            child: ElevatedButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () async {
                                      print('[UI] Button pressed: sign');
                                      await _captureAndAnalyze('sign');
                                    },
                              child: const Text('ป้าย'),
                            ),
                          ),
                          MouseRegion(
                            onEnter: (_) => _handleHover('เวลา'),
                            child: ElevatedButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () async {
                                      print('[UI] Button pressed: datetime');
                                      await _tts.tellDatetime();
                                    },
                              child: const Text('เวลา'),
                            ),
                          ),
                          MouseRegion(
                            onEnter: (_) => _handleHover('ถาม'),
                            child: ElevatedButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () async {
                                      print('[UI] Button pressed: ask');
                                      await _askQuestion();
                                    },
                              child: const Text('ถาม'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await _tts.speak('ปิดแอพ');
                          exit(0);
                        },
                        child: const Text('ออก'),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
