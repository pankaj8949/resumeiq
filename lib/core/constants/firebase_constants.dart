/// Firebase-specific constants
class FirebaseConstants {
  FirebaseConstants._();

  // Firestore Collections
  static const String users = 'users';
  static const String resumes = 'resumes';
  static const String resumeScores = 'resume_scores';
  static const String mockInterviews = 'mock_interviews';
  static const String interviewSessions = 'interview_sessions';

  // Firestore Fields
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String userId = 'userId';

  // Storage Paths
  static const String resumesPath = 'resumes';
  static const String profileImagesPath = 'profile_images';
  static const String uploadsPath = 'uploads';
}

