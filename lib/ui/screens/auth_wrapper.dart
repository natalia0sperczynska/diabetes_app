import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.status == AuthStatus.initial ||
            authViewModel.status == AuthStatus.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authViewModel.isAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
