part of '../utils/lib_files.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    /// Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    /// Fade Animation
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    /// Scale Animation
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    /// Start animation after short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _controller.forward();
    });

    /// Redirect after splash duration
    _navigateNext();
  }

  /// ✅ Check Login and Navigate
  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));

    final isLoggedIn = await BedtimeLocalStorage.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      ///  User already logged in → Project Selection
      Navigator.pushReplacementNamed(context, "/projectSelection");
    } else {
      ///  Not logged in → Login Page
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              "assets/images/splash_png.png",
              width: screenWidth * 0.80,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
