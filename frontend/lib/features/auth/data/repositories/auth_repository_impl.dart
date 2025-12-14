import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<User> register(String email, String password, String username) async {
    return await remoteDataSource.register(email, password, username);
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> resetPassword(String email) async {
    // Implementation for password reset
  }

  @override
  Future<User> loginWithGoogle() async {
    // Implementation for Google login
    throw UnimplementedError();
  }

  @override
  Future<User> loginWithApple() async {
    // Implementation for Apple login
    throw UnimplementedError();
  }

  @override
  Future<void> verifyEmail(String code) async {
    // Implementation for email verification
  }

  @override
  Future<void> resendVerificationEmail() async {
    // Implementation for resending verification email
  }
}