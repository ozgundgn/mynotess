import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    //send emial verification

    on<AuthEventSendEmailVerifaction>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(email: email, password: password);
      } on Exception catch (e) {
        emit(AuthStateRegistering(e));
      }
    });

    //initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });

    //verification

    //login

    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
        ),
      );
      await Future.delayed(const Duration(seconds: 3));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);

        if (user.isEmailVerified == false) {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ));

          emit(const AuthStateNeedsVerification());
        } else {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ));

          emit(AuthStateLoggedIn(user));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
        ));
      }
    });

    //logout

    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();

        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(null));
    });
  }
}
