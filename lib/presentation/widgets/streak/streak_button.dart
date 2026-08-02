import 'package:first_app/core/di/dependency_injection.dart';
import 'package:first_app/core/utils/streak_calculator.dart';
import 'package:first_app/domain/repositories/progress_repository.dart';
import 'package:first_app/presentation/pages/practice_calendar_page.dart';
import 'package:flutter/material.dart';

class StreakButton extends StatefulWidget {
  const StreakButton({super.key});

  @override
  State<StreakButton> createState() => _StreakButtonState();
}

class _StreakButtonState extends State<StreakButton> {
  late Future<Set<DateTime>> _practiceDatesFuture;

  @override
  void initState() {
    super.initState();
    _practiceDatesFuture = sl<ProgressRepository>().getPracticeDates();
  }

  void _reload() {
    setState(() {
      _practiceDatesFuture = sl<ProgressRepository>().getPracticeDates();
    });
  }

  Future<void> _showCalendar(Set<DateTime> practiceDates) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeCalendarPage(practiceDates: practiceDates),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<Set<DateTime>>(
      future: _practiceDatesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildButton(
            scheme,
            icon: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            label: 'Cargando racha...',
            onTap: null,
          );
        }

        final dates = snapshot.data ?? <DateTime>{};
        final streak = calculateStreak(dates, DateTime.now());
        final label = streak == 1 ? '1 día de racha' : '$streak días de racha';

        return _buildButton(
          scheme,
          icon: Icon(Icons.local_fire_department, color: scheme.primary, size: 28),
          label: label,
          onTap: snapshot.hasError
              ? _reload
              : () => _showCalendar(dates),
        );
      },
    );
  }

  Widget _buildButton(
    ColorScheme scheme, {
    required Widget icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: scheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const Icon(Icons.calendar_month, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
