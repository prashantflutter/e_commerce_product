import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  Future<(Failure?, String?)> login(String email, String password);
  Future<void> logout();
  Future<String?> getUserToken();
  Future<String?> getUserEmail();
  Future<bool> isLoggedIn();
}
