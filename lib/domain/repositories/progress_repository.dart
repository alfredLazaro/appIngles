import 'package:first_app/domain/entities/progress.dart';

abstract class ProgressRepository {
  Future<Map<int, int>> getAllLearnCounts();
  Future<void> batchUpdateLearnCounts(Map<int, int> updates);
  Future<void> updateLearnCount(int wordId, int newLearn);
  Future<Progress?> getByWordId(int wordId);
  Future<List<Progress>> getAll();
  Future<List<Progress>> getWithLearnGreaterThanZero();
  Future<Set<DateTime>> getPracticeDates();
}