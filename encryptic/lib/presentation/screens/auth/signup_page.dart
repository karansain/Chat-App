import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/SupabaseImageService.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/auth/auth_state.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  final SupabaseImageService _imageService = SupabaseImageService();

  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is SignupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message), backgroundColor: Colors.green));
            Navigator.pop(context);
          } else if (state is SignupFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(35.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    _inputField("Username", usernameController, context),
                    SizedBox(
                      height: 50,
                      child: Text(
                        'Username can only contain special characters and numbers (letters are not allowed)',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                    _inputField2("Email id", emailController, context),
                    const SizedBox(height: 20),
                    _inputField2(
                        "Password",
                        passwordController,
                        isPassword: true,
                        context),
                    const SizedBox(height: 20),
                    _inputField2(
                        "Confirm Password", confirmPasswordController, context,
                        isPassword: true),
                    const SizedBox(height: 30),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Radio<String>(
                              value: 'male',
                              groupValue: _selectedGender, // Bind groupValue to _selectedGender
                              activeColor: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer,
                              fillColor: MaterialStateProperty.all(
                                  Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer),
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedGender = value; // Update the selected gender
                                });
                              },
                            ),
                            Text(
                              'Male',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 50),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'female',
                              groupValue: _selectedGender, // Bind groupValue to _selectedGender
                              activeColor: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer,
                              fillColor: MaterialStateProperty.all(
                                  Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer),
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedGender = value; // Update the selected gender
                                });
                              },
                            ),
                            Text(
                              'Female',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _signUpButton(context),
                    const SizedBox(height: 20),
                    _login(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller, context,
      {bool isPassword = false}) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
    );
    return TextFormField(
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.deny(RegExp("[a-zA-Z]"))
      ],
      style: const TextStyle(color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: Theme.of(context).colorScheme.secondary,
        filled: true,
        hintStyle: const TextStyle(
          color: Colors.black54,
          fontFamily: 'Orbitron_black',
        ),
        enabledBorder: border,
        focusedBorder: border,
      ),
      obscureText: isPassword,
    );
  }

  Widget _inputField2(
      String hintText, TextEditingController controller, context,
      {bool isPassword = false}) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
    );
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: Theme.of(context).colorScheme.secondary,
        filled: true,
        hintStyle: const TextStyle(
          color: Colors.black54,
          fontFamily: 'Orbitron_black',
        ),
        enabledBorder: border,
        focusedBorder: border,
      ),
      obscureText: isPassword,
    );
  }

  Widget _signUpButton(BuildContext context) {
    return Container(
      height: 50.0,
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
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
        onPressed: () async {
          final username = usernameController.text;
          final email = emailController.text;
          final password = passwordController.text;
          final confirmPassword = confirmPasswordController.text;

            String bucket =
            _selectedGender == 'male' ? 'male_profiles' : 'female_profiles';

            // Fetch random image URL from the bucket
            String imageUrl = await _imageService.fetchRandomImage(bucket);
            print("Image URL: $imageUrl");

          if (password == confirmPassword) {
            final gender =
                _selectedGender ?? 'male'; // Default to 'male' if no selection
            context.read<AuthBloc>().add(SignupRequested(
              username: username,
              email: email,
              password: password,
              imageUrl: imageUrl,
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Passwords do not match")));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          'Sign up',
          style: TextStyle(
            fontSize: 25,
            color: Theme.of(context).colorScheme.primary,
            fontFamily: 'Orbitron_black',
          ),
        ),
      ),
    );
  }

  Widget _login(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Already have an account?",
            style: TextStyle(color: Colors.grey),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text(
              "Log in",
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                fontFamily: 'Orbitron_black',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
