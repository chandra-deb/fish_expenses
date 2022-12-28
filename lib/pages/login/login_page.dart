import 'package:fish_expenses/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatelessWidget {
  static const String routeName = '/login';

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    var signInLoading = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login '),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FontAwesomeIcons.fishFins,
              color: Colors.green,
              size: 150,
            ),
            StatefulBuilder(
              builder: (context, setState) {
                var authService = AuthService();
                if (signInLoading) {
                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: const CircularProgressIndicator(),
                  );
                }
                return ElevatedButton.icon(
                  onPressed: () async {
                    setState(() => signInLoading = true);
                    await authService.signInWithGoogle();
                    if (authService.currentUser == null) {
                      setState(() => signInLoading = false);
                    }
                  },
                  icon: const Icon(FontAwesomeIcons.google),
                  label: const Text('Sign In With Google'),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
