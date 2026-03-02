part of 'package:bedtime_stories/utils/lib_files.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const int _usernameMaxLength = 50;
  static const int _passwordMaxLength = 128;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  String? usernameError;
  String? passwordError;

  void _validateAndLogin() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      usernameError = username.isEmpty ? "Please enter your username" : null;
      passwordError = password.isEmpty ? "Please enter your password" : null;
    });

    if (usernameError != null || passwordError != null) return;

    context.read<BedtimeLoginBloc>().add(
      BedtimeLoginRequested(username, password),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
          color: Colors.white,
          child: BlocConsumer<BedtimeLoginBloc, BedtimeLoginState>(
            listener: (context, state) {
              if (state is BedtimeLoginSuccess) {
                Navigator.pushReplacementNamed(context, "/projectSelection");

              }

              if (state is BedtimeLoginFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },

            builder: (context, state) {
              final isLoading = state is BedtimeLoginLoading;

              return Stack(
                children: [
                  AbsorbPointer(
                    absorbing: isLoading,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Please enter your username and password\nto log in.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0XFF6B6B6B),
                            fontWeight: FontWeight.w400,
                            height: 1.9,
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// Username Field
                        AppTextField(
                          label: "User Name",
                          controller: usernameController,
                          maxLength: _usernameMaxLength,
                          errorText: usernameError,
                          onChanged: (value) {
                            if (usernameError == null) return;
                            setState(() {
                              usernameError = value.trim().isEmpty
                                  ? "Please enter your username"
                                  : null;
                            });
                          },
                        ),

                        const SizedBox(height: 18),

                        /// Password Field
                        AppTextField(
                          label: "Password",
                          controller: passwordController,
                          maxLength: _passwordMaxLength,
                          errorText: passwordError,
                          onChanged: (value) {
                            if (passwordError == null) return;
                            setState(() {
                              passwordError = value.trim().isEmpty
                                  ? "Please enter your password"
                                  : null;
                            });
                          },
                          obscureText: !isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 18,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 26),

                        /// Login Button
                        AppButton(
                          text: "Login",
                          onPressed: _validateAndLogin,
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withOpacity(0.65),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
