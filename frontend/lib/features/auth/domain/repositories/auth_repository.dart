import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String username);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> resetPassword(String email);
  Future<User> loginWithGoogle();
  Future<User> loginWithApple();
  Future<void> verifyEmail(String code);
  Future<void> resendVerificationEmail();
}