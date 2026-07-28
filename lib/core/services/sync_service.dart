import 'dart:async';
import 'package:first_app/domain/repositories/sync_repository.dart';

class SyncService {
  final SyncRepository _syncRepository;
  bool _isSyncing = false;
  Timer? _debounceTimer;

  SyncService({required SyncRepository syncRepository})
      : _syncRepository = syncRepository;

  bool get isSyncing => _isSyncing;

  Future<void> trySync() async {
    if (_isSyncing) return;

    final shouldSync = await _evaluateShouldSync();
    if (!shouldSync) return;

    _isSyncing = true;
    try {
      await _syncRepository.sync();
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _evaluateShouldSync() async {
    final pendingCount = await _syncRepository.countPending();
    if (pendingCount == 0) return false;

    if (pendingCount >= 10) return true;

    final lastSync = await _syncRepository.getLastSyncTime();
    if (lastSync == null) return true;

    return DateTime.now().difference(lastSync) >= const Duration(hours: 24);
  }

  /// Llamar después de completar una práctica
  void onPracticeCompleted() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 3), () {
      trySync();
    });
  }

  /// Llamar al reanudar la app
  Future<void> onAppResumed() async {
    await trySync();
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}