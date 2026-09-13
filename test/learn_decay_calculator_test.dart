import 'package:first_app/core/utils/learn_decay_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LearnDecayCalculator', () {
    test('isCandidate: 16-94 → true', () {
      expect(LearnDecayCalculator.isCandidate(16), isTrue);
      expect(LearnDecayCalculator.isCandidate(94), isTrue);
      expect(LearnDecayCalculator.isCandidate(15), isFalse);
      expect(LearnDecayCalculator.isCandidate(95), isFalse);
      expect(LearnDecayCalculator.isCandidate(100), isFalse);
    });

    test('penaltyForDay returns correct penalties', () {
      expect(LearnDecayCalculator.penaltyForDay(0), 0);
      expect(LearnDecayCalculator.penaltyForDay(1), 10);
      expect(LearnDecayCalculator.penaltyForDay(2), 5);
      expect(LearnDecayCalculator.penaltyForDay(3), 3);
      expect(LearnDecayCalculator.penaltyForDay(5), 3);
      expect(LearnDecayCalculator.penaltyForDay(10), 3);
    });

    test('decayedLearn applies floor 15', () {
      expect(LearnDecayCalculator.decayedLearn(20, 1), 15);
      expect(LearnDecayCalculator.decayedLearn(20, 2), 15);
      expect(LearnDecayCalculator.decayedLearn(20, 3), 17);
      expect(LearnDecayCalculator.decayedLearn(17, 1), 15);
      expect(LearnDecayCalculator.decayedLearn(94, 1), 84);
      expect(LearnDecayCalculator.decayedLearn(20, 0), 20);
      expect(LearnDecayCalculator.decayedLearn(20, -1), 20);
    });

    test('daysSince computes correct day difference', () {
      final ref = DateTime(2026, 9, 1);
      final now = DateTime(2026, 9, 3, 14, 30);
      expect(LearnDecayCalculator.daysSince(ref, now), 2);
    });

    test('daysSince returns 0 for same day', () {
      final now = DateTime(2026, 9, 3, 14, 30);
      expect(LearnDecayCalculator.daysSince(now, now), 0);
    });
  });
}
