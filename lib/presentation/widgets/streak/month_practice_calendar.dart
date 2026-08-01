import 'package:first_app/core/utils/streak_calculator.dart';
import 'package:flutter/material.dart';

class MonthPracticeCalendar extends StatefulWidget {
  final Set<DateTime> practiceDates;

  const MonthPracticeCalendar({super.key, required this.practiceDates});

  @override
  State<MonthPracticeCalendar> createState() => _MonthPracticeCalendarState();
}

class _MonthPracticeCalendarState extends State<MonthPracticeCalendar> {
  static const _weekdayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const _monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + delta,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        const SizedBox(height: 8),
        _buildWeekdayLabels(),
        const SizedBox(height: 4),
        _buildDaysGrid(),
        const SizedBox(height: 12),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _changeMonth(-1),
          tooltip: 'Mes anterior',
        ),
        Text(
          '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => _changeMonth(1),
          tooltip: 'Mes siguiente',
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    return Row(
      children: _weekdayLabels
          .map((label) => Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDaysGrid() {
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_visibleMonth.year, _visibleMonth.month, 1)
            .weekday -
        1;

    final cells = <Widget>[];
    for (var i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(_DayCell(
        date: DateTime(_visibleMonth.year, _visibleMonth.month, day),
        practiced: widget.practiceDates.contains(
          DateTime(_visibleMonth.year, _visibleMonth.month, day),
        ),
      ));
    }

    return Column(
      children: List.generate(
        (cells.length / 7).ceil(),
        (row) => Row(
          children: List.generate(7, (col) {
            final index = row * 7 + col;
            if (index >= cells.length) return const Expanded(child: SizedBox());
            return Expanded(child: cells[index]);
          }),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(scheme.primary),
        const SizedBox(width: 4),
        const Text('Practicado', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 16),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: scheme.outline, width: 1.5),
          ),
        ),
        const SizedBox(width: 4),
        const Text('Hoy', style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool practiced;

  const _DayCell({required this.date, required this.practiced});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = dateOnly(DateTime.now());
    final isToday = date == today;
    final isFuture = date.isAfter(today);

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: practiced ? scheme.primary : null,
          border: isToday && !practiced
              ? Border.all(color: scheme.outline, width: 1.5)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: isToday || practiced ? FontWeight.bold : FontWeight.normal,
            color: practiced
                ? scheme.onPrimary
                : isFuture
                    ? scheme.outlineVariant
                    : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
