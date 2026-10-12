import 'package:flutter/material.dart';

import '../service/auth_service.dart';
import '../widegt/loading_widget.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingWidget());
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Could not check login status.')),
          );
        }

        if (snapshot.data != null) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
