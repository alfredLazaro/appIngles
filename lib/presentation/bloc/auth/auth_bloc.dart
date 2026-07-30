import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/domain/repositories/auth_repository.dart';
import 'package:first_app/domain/repositories/sync_repository.dart';
import 'package:first_app/presentation/bloc/auth/auth_event.dart';
import 'package:first_app/presentation/bloc/auth/auth_state.dart';
import 'package:dio/dio.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SyncRepository _syncRepository;

  AuthBloc({
    required AuthRepository authRepository,
    required SyncRepository syncRepository,
  })  : _authRepository = authRepository,
        _syncRepository = syncRepository,
        super(const AuthInitial()) {
    on<CheckAuth>(_onCheckAuth);
    on<LoginSubmitted>(_onLogin);
    on<RegisterSubmitted>(_onRegister);
    on<ContinueAsGuest>(_onContinueAsGuest);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onCheckAuth(CheckAuth event, Emitter<AuthState> emit) async {
    final loggedIn = await _authRepository.isLoggedIn();
    if (loggedIn) {
      final session = await _authRepository.getUserSession();
      if (session != null) {
        emit(AuthSuccess(session));
        return;
      }
    }
    emit(const AuthGuest());
  }

  Future<void> _onLogin(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final session = await _authRepository.login(event.email, event.password);
      await _authRepository.saveSession(session);
      await _syncRepository.pullAndReconcile();
      emit(AuthSuccess(session));
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
    }
  }

  Future<void> _onRegister(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final session = await _authRepository.register(event.email, event.password);
      await _authRepository.saveSession(session);
      await _syncRepository.pullAndReconcile();
      emit(AuthSuccess(session));
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
    }
  }

  void _onContinueAsGuest(ContinueAsGuest event, Emitter<AuthState> emit) {
    emit(const AuthGuest());
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.clearSession();
    emit(const AuthGuest());
  }

  String _extractMessage(Object e) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) return 'Email o contraseña incorrectos';
      if (statusCode == 409) return 'Este email ya está registrado';
      if (statusCode == 404) return 'Ruta no encontrada en el servidor';
      if (statusCode != null) return 'Error del servidor (HTTP $statusCode)';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'El servidor no respondió a tiempo';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'No se pudo conectar con el servidor';
      }
    }
    final s = e.toString();
    if (s.contains('SocketException') || s.contains('Connection refused')) {
      return 'No se pudo conectar con el servidor';
    }
    return 'Error: ${e.toString().substring(0, e.toString().length.clamp(0, 120))}';
  }
}