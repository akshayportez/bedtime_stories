import 'package:bedtime_stories/app_ui/home/bloc/get_accounts_list_bloc/bedtime_get_accounts_list_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/get_accounts_list_bloc/bedtime_get_accounts_list_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/get_accounts_list_bloc/bedtime_get_accounts_list_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/get_bank_list_bloc/bedtime_get_bank_list_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/get_bank_list_bloc/bedtime_get_bank_list_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/get_bank_list_bloc/bedtime_get_bank_list_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/add_account_bloc/bedtime_add_account_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/add_account_bloc/bedtime_add_account_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/add_account_bloc/bedtime_add_account_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/get_category_list_bloc/bedtime_get_category_list_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/get_category_list_bloc/bedtime_get_category_list_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/get_category_list_bloc/bedtime_get_category_list_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/get_section_list_bloc/bedtime_get_section_list_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/get_section_list_bloc/bedtime_get_section_list_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/get_section_list_bloc/bedtime_get_section_list_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/get_tax_list_bloc/bedtime_get_tax_list_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/get_tax_list_bloc/bedtime_get_tax_list_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/get_tax_list_bloc/bedtime_get_tax_list_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/project_selection_bloc/bedtime_project_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/project_selection_bloc/bedtime_project_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/project_selection_bloc/bedtime_project_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_bloc/bedtime_payment_request_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_bloc/bedtime_payment_request_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_bloc/bedtime_payment_request_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_upload_bloc/bedtime_payment_request_upload_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_upload_bloc/bedtime_payment_request_upload_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_upload_bloc/bedtime_payment_request_upload_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_save_bloc/bedtime_payment_request_save_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_save_bloc/bedtime_payment_request_save_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_save_bloc/bedtime_payment_request_save_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_voucher_save_bloc/bedtime_payment_voucher_save_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_voucher_save_bloc/bedtime_payment_voucher_save_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_voucher_save_bloc/bedtime_payment_voucher_save_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_voucher_detail_bloc/bedtime_payment_voucher_detail_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_voucher_detail_bloc/bedtime_payment_voucher_detail_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_voucher_detail_bloc/bedtime_payment_voucher_detail_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_detail_bloc/bedtime_payment_request_detail_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_detail_bloc/bedtime_payment_request_detail_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/payment_request_detail_bloc/bedtime_payment_request_detail_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/voucher_report_bloc/bedtime_voucher_report_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/voucher_report_bloc/bedtime_voucher_report_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/voucher_report_bloc/bedtime_voucher_report_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/request_approve_bloc/bedtime_request_approve_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/request_approve_bloc/bedtime_request_approve_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/request_approve_bloc/bedtime_request_approve_repository.dart';
import 'package:bedtime_stories/app_ui/home/bloc/request_reject_bloc/bedtime_request_reject_api_provider.dart';
import 'package:bedtime_stories/app_ui/home/bloc/request_reject_bloc/bedtime_request_reject_bloc.dart';
import 'package:bedtime_stories/app_ui/home/bloc/request_reject_bloc/bedtime_request_reject_repository.dart';
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
      create: (_) => BedtimeGetAccountsListBloc(
        BedtimeGetAccountsListRepository(
          BedtimeGetAccountsListApiProvider(),
        ),
      ),
    ),
    BlocProvider(
      create: (_) => BedtimeGetBankListBloc(
        BedtimeGetBankListRepository(
          BedtimeGetBankListApiProvider(),
        ),
      ),
    ),
    BlocProvider(
      create: (_) => BedtimeAddAccountBloc(
        BedtimeAddAccountRepository(
          BedtimeAddAccountApiProvider(),
        ),
      ),
    ),
    BlocProvider(
      create: (_) => BedtimeGetCategoryListBloc(
        BedtimeGetCategoryListRepository(
          BedtimeGetCategoryListApiProvider(),
        ),
      ),
    ),
    BlocProvider(
      create: (_) => BedtimeGetSectionListBloc(
        BedtimeGetSectionListRepository(
          BedtimeGetSectionListApiProvider(),
        ),
      ),
    ),
    BlocProvider(
      create: (_) => BedtimeGetTaxListBloc(
        BedtimeGetTaxListRepository(
          BedtimeGetTaxListApiProvider(),
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
      create: (_) => BedtimePaymentRequestUploadBloc(
        BedtimePaymentRequestUploadRepository(
          BedtimePaymentRequestUploadApiProvider(),
        ),
      ),
    ),
    BlocProvider(
      create: (_) => BedtimePaymentRequestSaveBloc(
        BedtimePaymentRequestSaveRepository(
          BedtimePaymentRequestSaveApiProvider(),
        ),
      ),
    ),
    BlocProvider(
      create: (_) => BedtimePaymentVoucherSaveBloc(
        BedtimePaymentVoucherSaveRepository(
          BedtimePaymentVoucherSaveApiProvider(),
        ),
      ),
    ),
    BlocProvider(
      create: (_) => BedtimePaymentVoucherDetailBloc(
        BedtimePaymentVoucherDetailRepository(
          BedtimePaymentVoucherDetailApiProvider(),
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
    BlocProvider(
      create: (_) => BedtimeVoucherReportBloc(
        BedtimeVoucherReportRepository(
          BedtimeVoucherReportApiProvider(),
        ),
      ),
    ),
    BlocProvider(
      create: (_) => BedtimeRequestApproveBloc(
        BedtimeRequestApproveRepository(
          BedtimeRequestApproveApiProvider(),
        ),
      ),
    ),
    BlocProvider(
      create: (_) => BedtimeRequestRejectBloc(
        BedtimeRequestRejectRepository(
          BedtimeRequestRejectApiProvider(),
        ),
      ),
    ),
  ],
  child: const BedtimeStories(),
  )
);
}

