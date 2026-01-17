/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'ResumeAI';
  static const String appVersion = '1.0.0';

  // Collections
  static const String usersCollection = 'users';
  static const String resumesCollection = 'resumes';
  static const String resumeScoresCollection = 'resume_scores';
  static const String mockInterviewsCollection = 'mock_interviews';
  static const String interviewSessionsCollection = 'interview_sessions';

  // Storage Paths
  static const String resumesStoragePath = 'resumes';
  static const String profileImagesStoragePath = 'profile_images';

  // Resume Scoring
  static const int targetScore = 80;
  static const int maxScore = 100;
  static const int minScore = 0;

  // AI Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration apiTimeout = Duration(seconds: 30);

  // Resume Sections
  static const List<String> resumeSections = [
    'Personal Information',
    'Summary',
    'Education',
    'Experience',
    'Skills',
    'Projects',
    'Certifications',
  ];

  // File Types
  static const List<String> allowedResumeFormats = ['pdf', 'docx', 'doc'];
  static const int maxFileSizeMB = 10;
  static const int maxFileSizeBytes = maxFileSizeMB * 1024 * 1024;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

