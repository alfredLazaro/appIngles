import 'package:first_app/domain/entities/user_session.dart';

abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<UserSession?> getUserSession();
  Future<void> saveSession(UserSession session);
  Future<void> clearSession();
}