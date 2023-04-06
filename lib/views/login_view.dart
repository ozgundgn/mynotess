import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import '../services/auth/auth_exception.dart';
import '../services/auth/bloc/auth_bloc.dart';
import '../services/auth/bloc/auth_event.dart';
import '../services/auth/bloc/auth_state.dart';
import '../utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context: context,
              text: "Cannot find a user with the entered credentials.",
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
              context: context,
              text: "Wrong credentials.",
            );
          } else if (state.exception is GenericAuthExcepiton) {
            await showErrorDialog(
              context: context,
              text: "Authentication error.",
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.my_title),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                      'Please log in to your account in order to interact with and create notes!'),
                  TextField(
                    controller: _mail,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        hintText: 'Enter your email here.'),
                  ),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'Enter your password here.',
                    ),
                  ),
                  TextButton(
                      onPressed: () async {
                        final email = _mail.text;
                        final password = _password.text;
                        context
                            .read<AuthBloc>()
                            .add(AuthEventLogIn(email, password));
                      },
                      child: const Text('Login')),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            const AuthEventShouldRegister(),
                          ); //   Navigator.of(context)
                      //       .pushNamedAndRemoveUntil(registerRoute, (route) => false);
                    },
                    child: const Text('Not registered yet? Register here!'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            const AuthEventForgotPassword(),
                          ); //   Navigator.of(context)
                      //       .pushNamedAndRemoveUntil(registerRoute, (route) => false);
                    },
                    child: const Text('I forgot my password'),
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
