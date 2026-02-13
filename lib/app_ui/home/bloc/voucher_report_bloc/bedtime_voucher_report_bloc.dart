import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_voucher_report_event.dart';
import 'bedtime_voucher_report_repository.dart';
import 'bedtime_voucher_report_state.dart';

class BedtimeVoucherReportBloc
    extends Bloc<BedtimeVoucherReportEvent, BedtimeVoucherReportState> {
  final BedtimeVoucherReportRepository repository;

  BedtimeVoucherReportBloc(this.repository) : super(BedtimeVoucherReportInitial()) {
    on<BedtimeVoucherReportLoadRequested>(_onLoadReport);
  }

  Future<void> _onLoadReport(
    BedtimeVoucherReportLoadRequested event,
    Emitter<BedtimeVoucherReportState> emit,
  ) async {
    emit(BedtimeVoucherReportLoading());

    try {
      final rows = await repository.getVoucherReport(
        companyId: event.companyId,
        projectIds: event.projectIds,
        dFrom: event.dFrom,
        dTo: event.dTo,
        accountIds: event.accountIds,
        categoryIds: event.categoryIds,
        sectionIds: event.sectionIds,
        userIds: event.userIds,
        payModes: event.payModes,
      );
      emit(BedtimeVoucherReportLoaded(rows));
    } catch (e) {
      emit(BedtimeVoucherReportFailure(
        e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }
}
