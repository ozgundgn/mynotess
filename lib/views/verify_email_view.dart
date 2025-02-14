import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth/bloc/auth_bloc.dart';
import '../services/auth/bloc/auth_event.dart';

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
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                  "We've sent you an email verification. Please open it to try verify your account."),
              const Text(
                  "If you haven't recevied a verificiation email yet, press the button below."),
              TextButton(
                onPressed: () async {
                  context
                      .read<AuthBloc>()
                      .add(const AuthEventSendEmailVerifaction());
                },
                child: const Text('Send email verification'),
              ),
              TextButton(
                onPressed: () async {
                  context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                },
                child: const Text("Restart"),
              )
            ],
          ),
        ));
  }
}
