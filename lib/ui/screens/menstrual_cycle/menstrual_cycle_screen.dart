import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../view_models/menstrual_cycle_view_model.dart';
import '../../widgets/vibe/glitch.dart';
import 'widgets/cycle_status_hud.dart';
import 'widgets/insulin_insight_card.dart';
import 'widgets/tactical_calendar.dart';

class MenstrualCycleScreen extends StatefulWidget {
  const MenstrualCycleScreen({super.key});

  @override
  State<MenstrualCycleScreen> createState() => _MenstrualCycleScreenState();
}

class _MenstrualCycleScreenState extends State<MenstrualCycleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CycleViewModel>().fetchCycleData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Theme.of(context).scaffoldBackgroundColor),
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: Image.asset(
              'assets/images/grid.png',
              repeat: ImageRepeat.repeat,
              scale: 1.0,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: CyberGlitchText(
              "BIO-RHYTHM",
              style: GoogleFonts.vt323(
                  fontSize: 28, letterSpacing: 2.0, color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: Consumer<CycleViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.pinkAccent),
                );
              }

              final dateToCheck = _selectedDay ?? DateTime.now();
              final isExistingEntry =
                  viewModel.periodDates.any((d) => isSameDay(d, dateToCheck));

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CycleStatusHud(
                        dayOfCycle: viewModel.currentDayOfCycle,
                        phaseName: viewModel.phaseName,
                      ),
                      const SizedBox(height: 24),
                      InsulinInsightCard(
                        isHighResistancePhase:
                            viewModel.isHighInsulinResistance,
                        isHighSensitivityPhase:
                            viewModel.isSensitivityToInsulin,
                      ),
                      const SizedBox(height: 24),
                      TacticalCalendar(
                        focusedDay: _focusedDay,
                        selectedDay: _selectedDay,
                        periodDays: viewModel.periodDates,
                        onDaySelected: (selected, focused) {
                          setState(() {
                            _selectedDay = selected;
                            _focusedDay = focused;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (isExistingEntry) {
                              await viewModel.removeEntry(dateToCheck);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Entry removed from log.",
                                      style: GoogleFonts.iceland(fontSize: 16),
                                    ),
                                    backgroundColor: Colors.grey,
                                  ),
                                );
                              }
                            } else {
                              await viewModel.logPeriodStart(dateToCheck);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        Colors.pinkAccent.withOpacity(0.8),
                                    content: Text(
                                      "Cycle started on ${dateToCheck.toString().split(' ')[0]} logged!",
                                      style: GoogleFonts.iceland(fontSize: 16),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isExistingEntry
                                ? Colors.red.withOpacity(0.2)
                                : Colors.pinkAccent.withOpacity(0.8),
                            side: BorderSide(
                                color: isExistingEntry
                                    ? Colors.red
                                    : Colors.pinkAccent,
                                width: 2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0)),
                          ),
                          child: Text(
                            isExistingEntry
                                ? "REMOVE ENTRY"
                                : "LOG MENSTRUATION START",
                            style: GoogleFonts.iceland(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
