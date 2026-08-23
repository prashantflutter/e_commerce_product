import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthState {
  final bool isLoading;
  final String? email;
  final String? errorMessage;
  final bool isAuthenticated;

  const AuthState({
    required this.isLoading,
    this.email,
    this.errorMessage,
    required this.isAuthenticated,
  });

  factory AuthState.initial() =>
      const AuthState(isLoading: false, isAuthenticated: false);
  factory AuthState.loading() =>
      const AuthState(isLoading: true, isAuthenticated: false);
  factory AuthState.authenticated(String email) =>
      AuthState(isLoading: false, email: email, isAuthenticated: true);
  factory AuthState.unauthenticated({String? error}) =>
      AuthState(isLoading: false, errorMessage: error, isAuthenticated: false);

  AuthState copyWith({
    bool? isLoading,
    String? email,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      email: email ?? this.email,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthState.initial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    emit(AuthState.loading());
    final isLoggedIn = await _repository.isLoggedIn();
    if (isLoggedIn) {
      final email = await _repository.getUserEmail();
      emit(AuthState.authenticated(email ?? 'User'));
    } else {
      emit(AuthState.unauthenticated());
    }
  }

  Future<bool> login(String email, String password) async {
    emit(AuthState.loading());
    final (failure, token) = await _repository.login(email, password);

    if (failure != null) {
      emit(AuthState.unauthenticated(error: failure.message));
      return false;
    }

    if (token != null) {
      emit(AuthState.authenticated(email));
      return true;
    }

    emit(AuthState.unauthenticated(error: 'Unknown error occurred'));
    return false;
  }

  Future<void> logout() async {
    emit(AuthState.loading());
    await _repository.logout();
    emit(AuthState.unauthenticated());
  }
}
