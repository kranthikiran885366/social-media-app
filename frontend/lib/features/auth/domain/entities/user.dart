class User {
  final String id;
  final String email;
  final String username;
  final String? profileImage;
  final DateTime createdAt;
  final bool isVerified;
  final int dailyTimeLimit;
  final int reelsLimit;

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.profileImage,
    required this.createdAt,
    this.isVerified = false,
    this.dailyTimeLimit = 900, // 15 minutes default
    this.reelsLimit = 10,
  });
}