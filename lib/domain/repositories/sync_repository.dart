import 'package:first_app/domain/entities/outbox_event.dart';

abstract class SyncRepository {
  Future<int> countPending();
  Future<List<OutboxEvent>> selectReadyBatch(int limit);
  Future<void> markInFlight(List<int> ids);
  Future<void> deleteByIds(List<int> ids);
  Future<void> markForRetry(List<int> ids, int attempts, int backoffSeconds);
  Future<void> markFailed(List<int> ids);
  Future<bool> sync();
  Future<void> pullAndReconcile();
  Future<DateTime?> getLastSyncTime();
  Future<void> pullWordsByCategory(String category);
}