import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../themes/colors/app_colors.dart';

class TacticalCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final List<DateTime> periodDays;

  const TacticalCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.periodDays,
  });
  bool _isPeriodDay(DateTime day) {
    return periodDays.any((periodDay) => isSameDay(periodDay, day));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: Border(
          top: BorderSide(color: AppColors.mainBlue.withOpacity(0.5), width: 1),
          bottom: BorderSide(color: AppColors.mainBlue.withOpacity(0.5), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: focusedDay,
        calendarFormat: CalendarFormat.month,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,

        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            if (_isPeriodDay(day)) {
              return Center(
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.withOpacity(0.3),
                    border: Border.all(color: Colors.pinkAccent),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            }
            return null;
          },

          todayBuilder: (context, day, focusedDay) {
            if (_isPeriodDay(day)) {
              return Center(
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.withOpacity(0.5),
                    border: Border.all(color: AppColors.mainBlue, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text('${day.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              );
            }
            return null;
          },
        ),

        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: GoogleFonts.vt323(color: Colors.white, fontSize: 22),
          leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.mainBlue),
          rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.mainBlue),
        ),

        calendarStyle: CalendarStyle(
          defaultTextStyle: GoogleFonts.roboto(color: Colors.white70),
          weekendTextStyle: GoogleFonts.roboto(color: Colors.white60),
          outsideTextStyle: GoogleFonts.roboto(color: Colors.white24),

          todayDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.mainBlue),
            color: Colors.transparent,
          ),
          todayTextStyle: const TextStyle(color: AppColors.mainBlue, fontWeight: FontWeight.bold),

          selectedDecoration: const BoxDecoration(
            color: AppColors.mainBlue,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}