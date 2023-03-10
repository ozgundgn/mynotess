import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exception.dart';
import '../constants/routes.dart';
import '../services/auth/bloc/auth_bloc.dart';
import '../services/auth/bloc/auth_event.dart';
import '../services/auth/bloc/auth_state.dart';
import '../utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _mail;
  late final TextEditingController _password;
  @override
  void initState() {
    _mail = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _mail.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context: context, text: "Weak password");
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(
                context: context, text: "Email is already in use");
          } else if (state.exception is GenericAuthExcepiton) {
            await showErrorDialog(context: context, text: "Failed to register");
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context: context, text: "Invalid email!");
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(title: const Text('Register')),
          body: Column(
            children: [
              TextField(
                controller: _mail,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    const InputDecoration(hintText: 'Enter your email here.'),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                    hintText: 'Enter your password here.'),
              ),
              TextButton(
                  onPressed: () async {
                    final email = _mail.text;
                    final password = _password.text;

                    context.read<AuthBloc>().add(AuthEventRegister(
                          email,
                          password,
                        ));
                  },
                  child: const Text('Register')),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                },
                child: const Text('Already registered got login view'),
              )
            ],
          )),
    );
  }
}
