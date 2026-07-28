import 'package:first_app/data/datasources/local/user_dao.dart';
import 'package:first_app/domain/entities/user_session.dart';
import 'package:first_app/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final UserDao _userDao;
  final Dio _dio;
  final String _baseUrl;

  AuthRepositoryImpl({
    required UserDao userDao,
    required Dio dio,
    required String baseUrl,
  })  : _userDao = userDao,
        _dio = dio,
        _baseUrl = baseUrl;

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

  @override
  Future<UserSession> login(String email, String password) async {
    final response = await _dio.post(
      '$_baseUrl/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = response.data as Map<String, dynamic>;
    return UserSession(
      id: data['user_id'] as int,
      email: data['email'] as String,
      token: data['token'] as String,
    );
  }

  @override
  Future<UserSession> register(String email, String password) async {
    final response = await _dio.post(
      '$_baseUrl/auth/register',
      data: {'email': email, 'password': password},
    );
    final data = response.data as Map<String, dynamic>;
    return UserSession(
      id: data['user_id'] as int,
      email: data['email'] as String,
      token: data['token'] as String,
    );
  }
}