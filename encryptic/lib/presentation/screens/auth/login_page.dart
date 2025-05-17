import 'package:encryptic/presentation/screens/auth/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_page.dart';
import '../others/splash_screen.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/auth/auth_state.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/web_socket_service.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // String url = "ws://192.168.3.26:8080/ws";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: BlocProvider(
        create: (context) {
          final authRepository = AuthRepository();
          return AuthBloc(authRepository: authRepository);
        },
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) async {
            if (state is AuthFailure) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }

            if (state is AuthSuccess) {
              // Save data to SharedPreferences and navigate
              var srPref = await SharedPreferences.getInstance();
              srPref.setBool(SplashScreenState.KEY, true);

              print("sprf Done");

              // Navigate to home page
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              });
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      _inputField("Email", _emailController, context),
                      const SizedBox(height: 20),
                      _inputField("Password", _passwordController, context, isPassword: true),
                      const SizedBox(height: 30),
                      Container(
                        height: 50.0,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          shape: BoxShape.rectangle,
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primaryContainer,
                              Theme.of(context).colorScheme.secondaryContainer,
                            ],
                            end: Alignment.topCenter,
                            begin: Alignment.bottomCenter,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            final email = _emailController.text;
                            final password = _passwordController.text;
                            context.read<AuthBloc>().add(LoginRequested(email, password));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            'Log in',
                            style: TextStyle(
                              fontSize: 30,
                              color: Theme.of(context).colorScheme.primary,
                              fontFamily: 'Orbitron_black',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _signup(context),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller, context, {isPassword = false}) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
    );
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: Theme.of(context).colorScheme.secondary,
        filled: true,
        hintStyle: const TextStyle(color: Colors.black54),
        enabledBorder: border,
        focusedBorder: border,
      ),
      obscureText: isPassword,
    );
  }

  Widget _signup(context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an account?",
            style: TextStyle(color: Colors.grey),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignupPage()),
              );
            },
            child: Text(
              "Sign Up",
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
            ),
          ),
        ],
      ),
    );
  }
}


