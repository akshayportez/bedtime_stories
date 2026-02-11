import 'package:bedtime_stories/app_ui/home/bloc/project_selection_bloc/bedtime_project_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/project_selection_bloc/bedtime_project_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/project_selection_bloc/bedtime_project_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_bloc/bedtime_payment_request_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_bloc/bedtime_payment_request_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_bloc/bedtime_payment_request_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_detail_bloc/bedtime_payment_request_detail_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_detail_bloc/bedtime_payment_request_detail_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_detail_bloc/bedtime_payment_request_detail_repository.dart';
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
    BlocProvider(
      create: (_) => BedtimePaymentRequestBloc(
        BedtimePaymentRequestRepository(
          BedtimePaymentRequestApiProvider(),
        ),
      ),
    ),
    BlocProvider(
      create: (_) => BedtimePaymentRequestDetailBloc(
        BedtimePaymentRequestDetailRepository(
          BedtimePaymentRequestDetailApiProvider(),
        ),
      ),
    ),
  ],
  child: const BedtimeStories(),
  )
);
}
