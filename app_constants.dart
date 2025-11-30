class AppConstants {
  // App Info
  static const String appName = 'Linkify';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String commentsCollection = 'comments';
  static const String likesCollection = 'likes';
  static const String notificationsCollection = 'notifications';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String postImagesPath = 'post_images';

  // Pagination
  static const int postsPerPage = 10;
  static const int commentsPerPage = 20;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxBioLength = 160;
  static const int maxPostLength = 500;
  static const int maxCommentLength = 200;

  // Image Settings
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const double imageQuality = 0.8;

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration likeDuration = Duration(milliseconds: 300);
  static const Duration buttonPressDuration = Duration(milliseconds: 100);
}
