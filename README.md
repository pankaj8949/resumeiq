# ResumeIQ

AI-powered resume builder and interview preparation app built with Flutter.

## Features

- **AI Resume Builder**: Create ATS-optimized resumes with AI assistance
- **Resume Scoring**: Get detailed analysis and scoring of your resume (0-100 scale)
- **Mock Interview**: Practice with AI-powered mock interviews using Google Gemini
- **Export Options**: Export resumes as PDF and DOCX

## Tech Stack

- **Flutter** (Latest stable)
- **Dart 3+**
- **Clean Architecture** (Presentation, Domain, Data layers)
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, Storage)
- **AI**: Google Gemini API
- **PDF Generation**: syncfusion_flutter_pdf, printing
- **DOCX Support**: docx_to_text (parsing)

## Project Structure

```
lib/
 ├── core/                    # Core infrastructure
 │   ├── constants/          # App constants
 │   ├── errors/             # Error handling
 │   ├── network/            # API client
 │   ├── theme/              # App theme
 │   ├── utils/              # Utility functions
 │   └── widgets/            # Reusable widgets
 │
 ├── features/               # Feature modules
 │   ├── auth/              # Authentication
 │   ├── resume_builder/    # Resume building feature
 │   ├── resume_scoring/    # Resume scoring feature
 │   ├── mock_interview/    # Mock interview feature
 │   └── dashboard/         # Dashboard
 │
 ├── shared/                 # Shared code
 │   ├── models/            # Shared models
 │   ├── services/          # Shared services (Gemini, etc.)
 │   └── extensions/        # Dart extensions
 │
 └── main.dart              # App entry point
```

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (3.10.4 or higher)
- Dart SDK (3.10.4 or higher)
- Firebase project set up
- Google Gemini API key

### 2. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Google Sign-In method)
3. Create a Firestore database
4. Set up Firebase Storage
5. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
6. Place them in the respective platform folders

**Google Sign-In Configuration:**
- In Firebase Console, go to Authentication > Sign-in method
- Enable "Google" as a sign-in provider
- For Android: Add your app's SHA-1 fingerprint
- For iOS: Configure OAuth consent screen
- For Web: Add authorized domains

### 3. Gemini API Key Configuration

The app requires a Google Gemini API key for AI features. See **[GEMINI_API_SETUP.md](GEMINI_API_SETUP.md)** for detailed setup instructions.

**Quick Setup (Windows PowerShell):**
```powershell
# Get your API key from: https://makersuite.google.com/app/apikey
$env:GEMINI_API_KEY="your-api-key-here"
flutter run
```

**Quick Setup (macOS/Linux):**
```bash
# Get your API key from: https://makersuite.google.com/app/apikey
export GEMINI_API_KEY="your-api-key-here"
flutter run
```

**Alternative (Development):**
Create `lib/core/config/gemini_api_key.txt` and add your API key (one line, no quotes).

⚠️ **Never commit API keys to version control!**

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Generate Code

This project uses `freezed` and `json_serializable` for code generation. Run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6. Run the App

```bash
flutter run
```

## Firebase Security Rules 

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Resumes collection
    match /resumes/{resumeId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
    
    // Resume scores collection
    match /resume_scores/{scoreId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
    
    // Mock interviews collection
    match /mock_interviews/{interviewId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

### Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /resumes/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && 
        request.auth.uid == userId;
    }
    
    match /profile_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && 
        request.auth.uid == userId;
    }
  }
}
```

## Architecture

This project follows **Clean Architecture** principles:

- **Presentation Layer**: UI components, State management (Riverpod)
- **Domain Layer**: Business logic, Use cases, Entities, Repository interfaces
- **Data Layer**: Data sources, Repository implementations, Models

### Key Principles

- **Separation of Concerns**: Each layer has a specific responsibility
- **Dependency Inversion**: Domain layer doesn't depend on data layer
- **SOLID Principles**: Followed throughout the codebase
- **Feature-based Structure**: Features are self-contained modules

## Development Guidelines

1. **Error Handling**: Always use the centralized error handling system
2. **State Management**: Use Riverpod for all state management
3. **API Calls**: Use the centralized GeminiService for AI interactions
4. **Validation**: Use the Validators utility class for form validation
5. **Code Generation**: Run `build_runner` after modifying models with freezed

## Contributing

1. Follow the existing code structure
2. Write clean, maintainable code
3. Add appropriate error handling
4. Test your changes thoroughly
5. Update documentation as needed

## License

This project is private and proprietary.

## Next Steps

The foundation of the app is set up. The following features need implementation:

1. ✅ Core infrastructure and authentication
2. ⏳ Resume Builder (data models created, UI needs implementation)
3. ⏳ Resume Scoring (AI integration needed)
4. ⏳ Mock Interview (Gemini chat integration needed)
5. ⏳ PDF/DOCX export functionality
6. ⏳ Resume parsing from uploaded files

## Support

For issues or questions, please contact the development team.
