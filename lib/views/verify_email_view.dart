import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import '../services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Verfy Emial'),
        ),
        body: Column(
          children: [
            const Text(
                "We've sent you an email verification. Please open it to try verify your account."),
            const Text(
                "If you haven't recevied a verificiation email yet, press the button below."),
            TextButton(
              onPressed: () async {
                await AuthService.firebase().sendEmailVerification();
              },
              child: const Text('Send email verification'),
            ),
            TextButton(
              onPressed: () async {
                await AuthService.firebase().logOut();
                // ignore: use_build_context_synchronously
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text("Restart"),
            )
          ],
        ));
  }
}
