import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/dialogs/remove_account_dialog.dart';

import '../../services/auth/auth_service.dart';
import '../../services/auth/auth_user.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final AuthUser? _currentUser;
  @override
  void initState() {
    _currentUser = AuthService.firebase().currentUser;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final currentUser = AuthService.firebase().currentUser;
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateAccountRemoving) {
            if (state.exception != null) {
              await showErrorDialog(
                  context: context, text: state.exception.toString());
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text("My Profile Settings")),
          body: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextButton(
                        child: const Text("Remove My Account"),
                        onPressed: () async {
                          final sureRomevingResult =
                              await showRemoveAccountDialog(context);

                          if (sureRomevingResult) {
                            context.read<AuthBloc>().add(
                                  AuthEventAccountRemove(user: _currentUser),
                                );
                          }
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}
