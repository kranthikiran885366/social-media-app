import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.username,
    super.profileImage,
    required super.createdAt,
    super.isVerified,
    super.dailyTimeLimit,
    super.reelsLimit,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt']),
      isVerified: json['isVerified'] ?? false,
      dailyTimeLimit: json['dailyTimeLimit'] ?? 900,
      reelsLimit: json['reelsLimit'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
      'dailyTimeLimit': dailyTimeLimit,
      'reelsLimit': reelsLimit,
    };
  }
}