import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_payment_request_report_event.dart';
import 'bedtime_payment_request_report_repository.dart';
import 'bedtime_payment_request_report_state.dart';

class BedtimePaymentRequestReportBloc extends Bloc<
    BedtimePaymentRequestReportEvent, BedtimePaymentRequestReportState> {
  final BedtimePaymentRequestReportRepository repository;

  BedtimePaymentRequestReportBloc(this.repository)
      : super(BedtimePaymentRequestReportInitial()) {
    on<BedtimePaymentRequestReportLoadRequested>(_onLoadReport);
  }

  Future<void> _onLoadReport(
    BedtimePaymentRequestReportLoadRequested event,
    Emitter<BedtimePaymentRequestReportState> emit,
  ) async {
    emit(BedtimePaymentRequestReportLoading());

    try {
      final rows = await repository.getPaymentRequestReport(
        companyId: event.companyId,
        projectIds: event.projectIds,
        status: event.status,
        dFrom: event.dFrom,
        dTo: event.dTo,
        accountIds: event.accountIds,
        categoryIds: event.categoryIds,
        sectionIds: event.sectionIds,
        userIds: event.userIds,
      );
      emit(BedtimePaymentRequestReportLoaded(rows));
    } catch (e) {
      emit(BedtimePaymentRequestReportFailure(
        e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }
}
