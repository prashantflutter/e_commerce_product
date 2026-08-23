import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<(Failure?, String?)> login(String email, String password) async {
    try {
      // Simulate network request delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Simple email & password validation
      if (email.isEmpty || !email.contains('@')) {
        return (const AuthFailure('Please enter a valid email address'), null);
      }
      if (password.isEmpty || password.length < 6) {
        return (
          const AuthFailure('Password must be at least 6 characters'),
          null
        );
      }

      // Generate a mock token
      final dummyToken = 'mock_jwt_token_${email.split('@')[0]}';

      // Save session locally
      await localDataSource.cacheUserSession(email, dummyToken);

      return (null, dummyToken);
    } catch (e) {
      return (AuthFailure(e.toString()), null);
    }
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearUserSession();
  }

  @override
  Future<String?> getUserToken() async {
    return await localDataSource.getUserToken();
  }

  @override
  Future<String?> getUserEmail() async {
    return await localDataSource.getUserEmail();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.hasUserSession();
  }
}
