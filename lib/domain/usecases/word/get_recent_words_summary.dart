import 'package:first_app/domain/entities/word_sumary.dart';
import 'package:first_app/domain/repositories/word_repository.dart';

class GetRecentWordsSummaryUseCase {
  final WordRepository _repository;

  GetRecentWordsSummaryUseCase(this._repository);

  Future<List<WordSummary>> call({int limit = 9}) async {
    return await _repository.getRecentWordsSummary(limit: limit);
  }
}
