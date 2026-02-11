part of 'lib_files.dart';

class Routes {
  static final Map<String, Widget Function(BuildContext)> a = {
    '/': (context) => const SplashScreen(),
    '/login': (context) => const LoginScreen(),
    '/projectSelection': (_) => const ProjectSelectionScreen(),
    '/homeScreen': (_) => const HomeScreen(),
    '/createRequestPage': (_) => const CreateRequestPage(),
  };
}
