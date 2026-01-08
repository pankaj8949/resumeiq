# ResumeIQ Setup Guide

## Quick Start

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Code (Required)
This project uses `freezed` for immutable models and `json_serializable` for JSON serialization. You **must** run code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate files for:
- `lib/shared/models/user_model.dart` → `*.freezed.dart` and `*.g.dart`
- `lib/shared/models/resume_model.dart` → `*.freezed.dart` and `*.g.dart`
- `lib/shared/models/resume_score_model.dart` → `*.freezed.dart` and `*.g.dart`

### 3. Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Authentication (Google Sign-In method)
   - Create a Firestore database (start in test mode, then update rules)
   - Enable Firebase Storage
   
   **Important for Google Sign-In:**
   - In Firebase Console, go to Authentication > Sign-in method
   - Enable "Google" as a sign-in provider
   - Add your app's SHA-1 fingerprint (for Android)
   - Configure OAuth consent screen (for production)

2. **Download Configuration Files**
   - Android: Download `google-services.json` and place in `android/app/`
   - iOS: Download `GoogleService-Info.plist` and place in `ios/Runner/`

3. **Configure Firebase Rules**
   - See `README.md` for Firestore and Storage security rules

### 4. Gemini API Key

You need a Google Gemini API key:

1. Get API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Set as environment variable:

**Windows PowerShell:**
```powershell
$env:GEMINI_API_KEY="your-api-key-here"
```

**macOS/Linux:**
```bash
export GEMINI_API_KEY="your-api-key-here"
```

**For Production:**
- Store API key securely (use Flutter secure storage or remote config)
- Do NOT commit API keys to version control

### 5. Run the App

```bash
flutter run
```

## Important Notes

### Code Generation
- **Always run `build_runner` after modifying models with `@freezed`**
- Use `--delete-conflicting-outputs` flag to avoid conflicts
- For watch mode: `flutter pub run build_runner watch`

### Firebase Configuration
- Make sure Firebase is initialized before running the app
- Check Firebase console for proper project setup
- Verify authentication methods are enabled

### API Keys
- Never commit API keys to git
- Use environment variables or secure storage
- Add `.env` to `.gitignore` if using env files

## Troubleshooting

### Code Generation Errors
If you see errors about missing generated files:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Firebase Errors
- Verify `google-services.json` and `GoogleService-Info.plist` are in correct locations
- Check Firebase project settings
- Ensure Firebase is initialized before use

### Gemini API Errors
- Verify API key is set correctly
- Check API key permissions in Google AI Studio
- Ensure internet connection is available

## Next Steps

After setup:
1. ✅ Run code generation
2. ✅ Configure Firebase
3. ✅ Set Gemini API key
4. ⏳ Implement resume builder UI
5. ⏳ Implement resume scoring logic
6. ⏳ Implement mock interview feature
7. ⏳ Add PDF/DOCX export

