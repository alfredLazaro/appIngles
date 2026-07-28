import 'package:first_app/data/datasources/local/user_dao.dart';
import 'package:first_app/domain/entities/user_session.dart';
import 'package:first_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final UserDao _userDao;

  AuthRepositoryImpl({required UserDao userDao}) : _userDao = userDao;

  @override
  Future<bool> isLoggedIn() => _userDao.hasSession();

  @override
  Future<UserSession?> getUserSession() async {
    final data = await _userDao.getSession();
    if (data == null) return null;
    return UserSession(
      id: data['id'] as int,
      email: data['email'] as String,
      token: data['token'] as String? ?? '',
    );
  }

  @override
  Future<void> saveSession(UserSession session) async {
    await _userDao.saveSession({
      'id': session.id,
      'email': session.email,
      'token': session.token,
    });
  }

  @override
  Future<void> clearSession() => _userDao.clearSession();
}