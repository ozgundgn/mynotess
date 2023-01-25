import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes/constants/routes.dart';

import '../utilities/show_error_dialog.dart';

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
                    final userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: email, password: password);
                    devtools.log(userCredential.toString());
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(notesRoute, (_) => false);
                  } on FirebaseAuthException catch (e) {
                    devtools.log(e.code);
                    final user = await FirebaseAuth.instance.currentUser;
                    devtools.log(user.toString());
                    if (e.code == 'user-not-found') {
                      await showErrorDialog(context, "User not found.");
                    } else if (e.code == "wrong-password") {
                      await showErrorDialog(context, "Wrong password.");
                    } else {
                      await showErrorDialog(context, 'Error: ${e.code}');
                    }
                  } catch (e) {
                    await showErrorDialog(context, 'Error: ${e.toString()}');
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
