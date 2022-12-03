import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_expenses/pages/login/login_page.dart';
import 'package:fish_expenses/services/auth_service.dart';
import 'package:flutter/material.dart';

import '../sell/sell_page.dart';

class HomePage extends StatelessWidget {
  static const String routeName = '/';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: AuthService().authStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text('Loading'),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Something wert wrong'),
            );
          } else if (snapshot.data != null) {
            return const SellPage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
