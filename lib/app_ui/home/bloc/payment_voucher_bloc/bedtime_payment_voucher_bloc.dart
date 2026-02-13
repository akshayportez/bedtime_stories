import 'package:bedtime_stories/app_ui/home/bloc/payment_voucher_bloc/bedtime_payment_voucher_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_payment_voucher_event.dart';
import 'bedtime_payment_voucher_state.dart';

class BedtimePaymentVoucherBloc
    extends Bloc<BedtimePaymentVoucherEvent, BedtimePaymentVoucherState> {
  final BedtimePaymentVoucherRepository repository;

  BedtimePaymentVoucherBloc(this.repository)
      : super(BedtimePaymentVoucherInitial()) {
    on<BedtimePaymentVoucherLoadRequested>(_onLoadVouchers);
    on<BedtimePaymentVoucherSearchRequested>(_onSearchVouchers);
  }

  Future<void> _onLoadVouchers(
    BedtimePaymentVoucherLoadRequested event,
    Emitter<BedtimePaymentVoucherState> emit,
  ) async {
    emit(BedtimePaymentVoucherLoading());

    try {
      final vouchers = await repository.getPaymentVouchers(
        companyId: event.companyId,
        projectId: event.projectId,
        userActionId: event.userActionId,
        search: event.search,
        statusFilter: event.statusFilter,
        dFrom: event.dFrom,
        dTo: event.dTo,
      );

      emit(BedtimePaymentVoucherLoaded(vouchers));
    } catch (e) {
      emit(BedtimePaymentVoucherFailure(
        e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }

  Future<void> _onSearchVouchers(
    BedtimePaymentVoucherSearchRequested event,
    Emitter<BedtimePaymentVoucherState> emit,
  ) async {
    emit(BedtimePaymentVoucherLoading());

    try {
      final vouchers = await repository.getPaymentVouchers(
        companyId: event.companyId,
        projectId: event.projectId,
        userActionId: event.userActionId,
        search: event.search,
        statusFilter: event.statusFilter,
        dFrom: event.dFrom,
        dTo: event.dTo,
      );

      emit(BedtimePaymentVoucherLoaded(vouchers));
    } catch (e) {
      emit(BedtimePaymentVoucherFailure(
        e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }
}
