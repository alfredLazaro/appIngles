class LearnDecayCalculator {
  LearnDecayCalculator._();

  static const int floor = 15;
  static const int max = 95;

  static bool isCandidate(int learn) => learn > floor && learn < max;

  static int penaltyForDay(int ordinalDay) {
    if (ordinalDay <= 0) return 0;
    if (ordinalDay == 1) return 10;
    if (ordinalDay == 2) return 5;
    return 3;
  }

  static int decayedLearn(int currentLearn, int daysNotPracticed) {
    if (daysNotPracticed <= 0) return currentLearn;
    final penalty = penaltyForDay(daysNotPracticed);
    final result = currentLearn - penalty;
    return result < floor ? floor : result;
  }

  static int daysSince(DateTime referenceDate, DateTime now) {
    final refDate = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    final nowDate = DateTime(now.year, now.month, now.day);
    return nowDate.difference(refDate).inDays;
  }
}
