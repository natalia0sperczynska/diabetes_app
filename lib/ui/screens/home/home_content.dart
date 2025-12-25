import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:diabetes_app/ui/widgets/vibe/glitch.dart';
import 'package:diabetes_app/ui/widgets/snack_bars/awesome_snack_bar.dart';
import 'package:diabetes_app/services/dexcom_service.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../themes/colors/app_colors.dart';
import '../../view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isLoading = false;
  String _glucoseData = '';

  Future<void> _loadDexcomData() async {
    setState(() {
      _isLoading = true;
      _glucoseData = 'Loading data...';
    });

    try {
      final result = await DexcomService.getCurrentGlucoseWithCredentials();

      if (result['success']) {
        setState(() {
          _glucoseData = '''
Glucose: ${result['value']} mg/dL
Trend: ${result['trend']}
Time: ${result['time']}
''';
        });

        if (mounted) {
          SnackbarUtils.showAwesomeSnackbar(
            context,
            title: "Success",
            message: "Dexcom data loaded!",
            contentType: ContentType.success,
          );
        }
      } else {
        setState(() {
          _glucoseData = 'Error: ${result['error']}';
        });

        if (mounted) {
          SnackbarUtils.showAwesomeSnackbar(
            context,
            title: "Error",
            message: result['error'],
            contentType: ContentType.failure,
          );
        }
      }
    } catch (e) {
      setState(() {
        _glucoseData = 'Connection Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CyberGlitchText(
                viewModel.welcomeMessage,
                style:
                    GoogleFonts.vt323(fontSize: 32, color: Theme.of(context).colorScheme.onPrimary),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _isLoading ? null : _loadDexcomData,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : CyberGlitchText(
                        "Load Data",
                        style: GoogleFonts.vt323(
                            fontSize: 32,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
              ),
            ],
          ),
          const SizedBox(width: 40),
          if (_glucoseData.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: CyberGlitchText(
                _glucoseData,
                style: GoogleFonts.vt323(
                    fontSize: 32, color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
        ],
      ),
    );
  }
}
