import 'package:first_app/presentation/widgets/streak/month_practice_calendar.dart';
import 'package:flutter/material.dart';

class PracticeCalendarPage extends StatelessWidget {
  final Set<DateTime> practiceDates;

  const PracticeCalendarPage({super.key, required this.practiceDates});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Días de práctica'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: MonthPracticeCalendar(practiceDates: practiceDates),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
