# AI Smart Glasses Flutter App

A Flutter application for AI-powered image analysis with text-to-speech output.

## Features

- 📷 **Camera Integration** - Capture images with device camera or upload from gallery
- 🤖 **AI Analysis** - 6 different analysis modes:
  - **สั้น** (Short) - Brief image description (1-2 sentences)
  - **ละเอียด** (Detail) - Detailed description with colors and shapes
  - **อ่าน** (Read) - OCR text extraction
  - **ป้าย** (Signs) - Signage text recognition
  - **เวลา** (Time) - Current time announcement
  - **ถาม** (Ask) - Free-form Q&A about images
- 🔊 **Thai Text-to-Speech** - Hear AI responses in Thai language
- 🎤 **Voice Input** - Ask questions using your microphone (web only)
- 🌐 **Multi-Platform** - Works on web, mobile (Android/iOS), and desktop (Windows)

## Getting Started

### Prerequisites

- Flutter SDK (>=2.17.0)
- Dart SDK
- Google Gemini API Key

### Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Aon371/ai_glasses.git
   cd ai_glasses
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Add your API key:**
   - Edit `lib/services/config.dart`
   - Replace `YOUR_API_KEY` with your Google Gemini API key

4. **Run the app:**

   **Web:**
   ```bash
   flutter run -d chrome --web-port=5000
   ```

   **Android:**
   ```bash
   flutter run
   ```

   **iOS:**
   ```bash
   flutter run -d ios
   ```

## Project Structure

```
lib/
├── main.dart                 # Main app entry point
├── services/
│   ├── config.dart          # API configuration
│   ├── genai_service.dart   # Google Gemini API integration
│   └── tts_service.dart     # Text-to-speech service
web/
├── index.html               # Web entry point
└── manifest.json            # Web app manifest
windows/
└── [Windows desktop files]
```

## Dependencies

- `camera`: Device camera access
- `image_picker`: Gallery and camera picker
- `flutter_tts`: Thai text-to-speech
- `http`: API requests
- `permission_handler`: Camera permissions

## API Integration

This app uses Google Gemini 2.5 Flash Lite model for image analysis.

**API Key Setup:**
1. Get a free API key from [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Update the key in `lib/services/config.dart`

## Usage

### Web Version
1. Visit `http://localhost:5000`
2. Click any analysis button
3. Allow camera access in the browser prompt
4. Capture or select an image
5. Hear the AI analysis

### Mobile/Desktop Version
1. Open the app
2. Point camera at object/text
3. Tap analysis button
4. Hear the result via speaker

### Voice Input (Web)
1. Click "ถาม" (Ask) button
2. Click "🎤 ใช้ไมล์" (Use Microphone)
3. Speak your question
4. Get voice response

## Troubleshooting

### Camera not working on web:
- Use HTTPS (not HTTP) or localhost
- Check browser camera permissions
- Use a compatible browser (Chrome, Firefox, Edge)

### API errors:
- Verify API key is valid and has quota
- Check internet connection
- Ensure model name is correct

### TTS not working:
- Tamil language pack might not be installed on some devices
- Check device TTS settings
- Volume should be turned up

## Development

### Hot Reload
While running:
- Press `r` in terminal for hot reload
- Press `R` for hot restart

### Build for Production

**Web:**
```bash
flutter build web
```

**Android:**
```bash
flutter build apk
```

**iOS:**
```bash
flutter build ios
```

## License

This project is open source and available under the MIT License.

## Author

AI Glasses Development Team

## Support

For issues and feature requests, please open an issue on GitHub.
