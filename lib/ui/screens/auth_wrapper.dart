import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/statistics_view_model.dart';
import '../view_models/analysis_view_model.dart';
import '../themes/colors/app_colors.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.status == AuthStatus.loading ||
            authViewModel.status == AuthStatus.initial) {
          return Scaffold(
            backgroundColor: AppColors.darkBlue2,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo_diabeto.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 40),

                  // Loading indicator
                  const CircularProgressIndicator(
                    color: AppColors.mainBlue,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),

                  // Loading text
                  const Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show home if authenticated
        if (authViewModel.status == AuthStatus.authenticated) {
          // Push the logged-in user's glucoseEmail to view models
          final glucoseEmail = authViewModel.currentUser?.glucoseEmail ??
              'anniefocused@gmail.com';
          context.read<StatisticsViewModel>().setUserEmail(glucoseEmail);
          context.read<AnalysisViewModel>().setUserEmail(glucoseEmail);

          return const HomeScreen();
        }

        // Show login for unauthenticated or error
        return const LoginScreen();
      },
    );
  }
}
