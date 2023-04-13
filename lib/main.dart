import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/helpers/loading/loading_screen.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';
import 'package:mynotes/views/forgot_password_view.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:mynotes/views/notes/notes_view.dart';
import 'package:mynotes/views/profile/settings_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';
import 'constants/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BlocProvider(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: MaterialApp(
        supportedLocales: AppLocalizations
            .supportedLocales, //yukarda verdiğimiz yolda zaten konumlar tanımlı old. için kendimiz bir liste üretmemeliyiz.
        localizationsDelegates: AppLocalizations
            .localizationsDelegates, //pelase localize your own widget,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
        // home: BlocProvider<AuthBloc>(
        //     create: (context) => AuthBloc(
        //         FirebaseAuthProvider()), // burada AuthBloc contexte injecct oluyor.
        //     child: const HomePage()),
        routes: {
          createOrUpdateNoteRoute: (context) => const CreateUpdatNoteView(),
          profileSettingsRoute: (context) => const SettingsView()
        },
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state.isLoading) {
        LoadingScreen().show(
          context: context,
          text: state.loadingText ?? 'Please wait a moment',
        );
      } else {
        LoadingScreen().hide();
      }
    }, builder: (context, state) {
      //blocbuilder is not supposed to have any side affects. taht is the job of the block listener
      //but we also need bloclistener to show state.isloagin and loading screen.
      //blocconsumer is solution. blocconsumer builds on top of a block builder and a block listener so
      //it allows you to do both things at the same time
      //that is why we changed the blocBuilder to bloccosnumer

      if (state is AuthStateLoggedIn) {
        return const NotesView();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthStateRegistering) {
        return const RegisterView();
      } else if (state is AuthStateForgotPassword) {
        return const ForgotPasswordView();
      } else if (state is AuthStateAccountRemoving) {
        return const SettingsView();
      } else {
        return const CircularProgressIndicator();
      }
    });
    //   return FutureBuilder(
    //     future: AuthService.firebase().initialize(),
    //     builder: (context, snapshot) {
    //       switch (snapshot.connectionState) {
    //         case ConnectionState.done:
    //           final user = AuthService.firebase().currentUser;
    //           if (user != null) {
    //             if (user.isEmailVerified) {
    //               return const NotesView();
    //             } else {
    //               return const VerifyEmailView();
    //             }
    //           } else {
    //             return const LoginView();
    //           }
    //         default:
    //           return const CircularProgressIndicator();
    //       }
    //     },
    //   );
    // }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late final TextEditingController _controller;

//   @override
//   void initState() {
//     _controller = TextEditingController();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => CounterBloc(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Testing bloc'),
//         ),
//         body: BlocConsumer<CounterBloc, CounterState>(
//           listener: (context, state) {
//             _controller.clear();
//           },
//           builder: ((context, state) {
//             final invalidValue =
//                 (state is CounterStateInValid) ? state.invalidValue : '';

//             return Column(
//               children: [
//                 Text('Current value=> ${state.value}'),
//                 Visibility(
//                   child: Text('Invalid input: $invalidValue'),
//                   visible: state is CounterStateInValid,
//                 ),
//                 TextField(
//                   controller: _controller,
//                   decoration: const InputDecoration(
//                     hintText: 'Enter a number here:',
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//                 Row(
//                   children: [
//                     TextButton(
//                       child: const Text('-'),
//                       onPressed: () {
//                         context
//                             .read<
//                                 CounterBloc>() // This gives o access to your bloc that has created by blocprovider.
//                             .add(DecrementEvent(_controller
//                                 .text)); // This is how you send events to your block
//                       },
//                     ),
//                     TextButton(
//                       child: const Text('+'),
//                       onPressed: () {
//                         context
//                             .read<
//                                 CounterBloc>() // This gives o access to your bloc that has created by blocprovider.
//                             .add(IncrementEvent(_controller
//                                 .text)); // This is how you send events to your block
//                       },
//                     ),
//                   ],
//                 )
//               ],
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

// @immutable
// abstract class CounterState {
//   final int value;

//   const CounterState(this.value);
// }

// class CounterStateValid extends CounterState {
//   const CounterStateValid(int value) : super(value);
// }

// class CounterStateInValid extends CounterState {
//   final String invalidValue;

//   const CounterStateInValid(
//       {required String this.invalidValue, required int previousValue})
//       : super(previousValue);
// }

// @immutable
// abstract class CounterEvent {
//   final String value;
//   const CounterEvent(this.value);
// }

// class IncrementEvent extends CounterEvent {
//   const IncrementEvent(String value) : super(value);
// }

// class DecrementEvent extends CounterEvent {
//   const DecrementEvent(String value) : super(value);
// }

// class CounterBloc extends Bloc<CounterEvent, CounterState> {
//   CounterBloc() : super(const CounterStateValid(0)) {
//     on<IncrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value);
//       if (integer == null) {
//         emit(CounterStateInValid(
//           invalidValue: event.value,
//           previousValue: state.value,
//         ));
//       } else {
//         emit(CounterStateValid(state.value + integer));
//       }
//     });

//     on<DecrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value);
//       if (integer == null) {
//         emit(CounterStateInValid(
//           invalidValue: event.value,
//           previousValue: state.value,
//         ));
//       } else {
//         emit(CounterStateValid(state.value - integer));
//       }
//     });
  }
}
