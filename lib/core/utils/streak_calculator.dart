DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

int calculateStreak(Set<DateTime> practiceDates, DateTime today) {
  if (practiceDates.isEmpty) return 0;

  final days = practiceDates.map(dateOnly).toSet();

  var cursor = dateOnly(today);
  if (!days.contains(cursor)) {
    cursor = dateOnly(today.subtract(const Duration(days: 1)));
  }

  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = dateOnly(cursor.subtract(const Duration(days: 1)));
  }
  return streak;
}
