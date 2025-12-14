import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;

  AuthBloc(this._loginUseCase) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RegisterRequested>(_onRegisterRequested);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<AppleLoginRequested>(_onAppleLoginRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<VerifyEmailRequested>(_onVerifyEmailRequested);
    on<ResendVerificationRequested>(_onResendVerificationRequested);
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await ApiService.login(event.email, event.password);
      if (result['success']) {
        await ApiService.setToken(result['data']['token']);
        final userData = result['data']['user'];
        final user = User(
          id: userData['id'],
          email: userData['email'],
          username: userData['username'],
          createdAt: DateTime.parse(userData['createdAt']),
        );
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError(result['error']));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    emit(AuthUnauthenticated());
  }

  void _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    // Check if user is authenticated - mock implementation
    // In real app, check stored token/session
    await Future.delayed(const Duration(milliseconds: 500));
    emit(AuthUnauthenticated());
  }

  void _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await ApiService.register({
        'email': event.email,
        'username': event.username,
        'password': event.password,
      });
      if (result['success']) {
        await ApiService.setToken(result['data']['token']);
        final userData = result['data']['user'];
        final user = User(
          id: userData['id'],
          email: userData['email'],
          username: userData['username'],
          createdAt: DateTime.parse(userData['createdAt']),
        );
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError(result['error']));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onGoogleLoginRequested(GoogleLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthError('Google login not implemented'));
  }

  void _onAppleLoginRequested(AppleLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthError('Apple login not implemented'));
  }

  void _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthUnauthenticated()); // Password reset email sent
  }

  void _onVerifyEmailRequested(VerifyEmailRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthUnauthenticated()); // Email verified
  }

  void _onResendVerificationRequested(ResendVerificationRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthUnauthenticated()); // Verification resent
  }
}