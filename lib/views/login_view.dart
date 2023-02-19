import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import '../services/auth/auth_exception.dart';
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
    return Scaffold(
        appBar: AppBar(title: const Text("Login")),
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
              decoration:
                  const InputDecoration(hintText: 'Enter your password here.'),
            ),
            TextButton(
                onPressed: () async {
                  final email = _mail.text;
                  final password = _password.text;
                  try {
                    await AuthService.firebase()
                        .logIn(email: email, password: password);

                    final user = AuthService.firebase().currentUser;
                    if (user?.isEmailVerified ?? false) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(notesRoute, (_) => false);
                    } else {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(verifyRoute, (_) => false);
                    }
                  } on UserNotFoundAuthException {
                    await showErrorDialog(
                        context: context, text: "User not found.");
                  } on WrongPasswordAuthException {
                    await showErrorDialog(
                        context: context, text: "Wrong password.");
                  } on GenericAuthExcepiton {
                    await showErrorDialog(
                        context: context, text: 'Error: something happened');
                  } catch (e) {
                    await showErrorDialog(
                        context: context, text: 'Error: ${e.toString()}');
                  }
                },
                child: const Text('Login')),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('Not registered yet? Register here!'),
            )
          ],
        ));
  }
}
