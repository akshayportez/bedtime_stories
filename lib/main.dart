import 'package:bedtime_stories/app_ui/home/bloc/project_selection_bloc/bedtime_project_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/project_selection_bloc/bedtime_project_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/project_selection_bloc/bedtime_project_repository.dart';
import 'package:bedtime_stories/app_ui/login/bloc/bedtime_auth_api_provider.dart';
import 'package:bedtime_stories/app_ui/login/bloc/bedtime_auth_repository.dart';
import 'package:bedtime_stories/app_ui/login/bloc/bedtime_login_bloc.dart';
import 'package:bedtime_stories/utils/lib_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (_) => BedtimeLoginBloc(
        BedtimeAuthRepository(BedtimeAuthApiProvider()),
      ),
    ),
    BlocProvider(
      create: (_) => BedtimeProjectBloc(
        BedtimeProjectRepository(
          BedtimeProjectApiProvider(),
        ),
      ),
    ),
  ],
  child: const BedtimeStories(),
  )
);
}
