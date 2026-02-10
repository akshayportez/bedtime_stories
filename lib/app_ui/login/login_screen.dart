part of 'package:bedtime_stories/utils/lib_files.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;

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
          child: BlocListener<BedtimeLoginBloc, BedtimeLoginState>(
            listener: (context, state) {
              if (state is BedtimeLoginLoading) {
                // show loader
              }

              if (state is BedtimeLoginSuccess) {
                Navigator.pushReplacementNamed(context, "/projectSelection");

              }

              if (state is BedtimeLoginFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
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
                ),

                const SizedBox(height: 18),

                /// Password Field
                AppTextField(
                  label: "Password",
                  controller: passwordController,
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
                  onPressed: () {
                    context.read<BedtimeLoginBloc>().add(
                      BedtimeLoginRequested(
                        usernameController.text.trim(),
                        passwordController.text.trim(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
