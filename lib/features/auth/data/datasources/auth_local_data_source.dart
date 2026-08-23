import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/constants.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUserSession(String email, String token);
  Future<void> clearUserSession();
  Future<String?> getUserToken();
  Future<String?> getUserEmail();
  Future<bool> hasUserSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheUserSession(String email, String token) async {
    await sharedPreferences.setString(AppConstants.userEmailKey, email);
    await sharedPreferences.setString(AppConstants.userTokenKey, token);
  }

  @override
  Future<void> clearUserSession() async {
    await sharedPreferences.remove(AppConstants.userEmailKey);
    await sharedPreferences.remove(AppConstants.userTokenKey);
  }

  @override
  Future<String?> getUserToken() async {
    return sharedPreferences.getString(AppConstants.userTokenKey);
  }

  @override
  Future<String?> getUserEmail() async {
    return sharedPreferences.getString(AppConstants.userEmailKey);
  }

  @override
  Future<bool> hasUserSession() async {
    final token = sharedPreferences.getString(AppConstants.userTokenKey);
    return token != null && token.isNotEmpty;
  }
}
