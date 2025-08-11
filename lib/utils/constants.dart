class AppConstants {
  static const String appName = 'Help App';
  static const double localRadiusKm = 10.0;
  static const int otpLength = 6;
  static const int postExpiryHours = 24;
  static const int chatExpiryHours = 1;
  
  // Collection names
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  
  // Post status
  static const String statusAwaitingResponse = 'awaiting_response';
  static const String statusHelperFound = 'helper_found';
  static const String statusCompleted = 'completed';
}