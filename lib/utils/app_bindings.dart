part of 'lib_files.dart';



class BedtimeStories extends StatefulWidget {
  const BedtimeStories({super.key});

  @override
  BedtimeStoriesState createState() => BedtimeStoriesState();
}

var navigatorKey = GlobalKey<NavigatorState>();

class BedtimeStoriesState extends State<BedtimeStories> {
  @override
  void initState() {
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [routeObserver],
        debugShowCheckedModeBanner: false,
        title: 'Bedtime Stories',
        theme: AppTheme.appThemeConfig,
        initialRoute: '/',
        routes: Routes.a,
        builder: (context, child) {
          return SafeArea(
            child: child!,
          );
        }

    );
  }
}
