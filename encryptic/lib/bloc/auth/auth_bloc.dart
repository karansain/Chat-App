import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/user_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/user_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final UserPreferences userPreferences = UserPreferences();
  final UserRepository userRepository = UserRepository();

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
  }

  // Handle LoginRequested event
  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Get login response
      final result = await authRepository.login(event.email, event.password);
      print("printing result");
      print(result['userId'].runtimeType);

      // Store user data (non-sensitive) in SharedPreferences
      await userPreferences.saveUserData(result['userId'], result['username'], result['imageUrl'], event.email);


      // Emit success state with username and image URL
      emit(AuthSuccess(result['username'], result['imageUrl']));
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  // Handle SignupRequested event
  Future<void> _onSignupRequested(SignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Get signup response
      final result = await authRepository.signup(
        event.username,
        event.email,
        event.password,
        event.imageUrl,
      );

      // Emit SignupSuccess state with message
      emit(SignupSuccess(result));
    } catch (error) {
      emit(SignupFailure(error.toString()));
    }
  }
}
