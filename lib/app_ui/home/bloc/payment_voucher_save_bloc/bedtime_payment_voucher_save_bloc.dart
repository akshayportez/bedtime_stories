import 'package:bedtime_stories/app_ui/home/bloc/payment_voucher_save_bloc/bedtime_payment_voucher_save_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_payment_voucher_save_event.dart';
import 'bedtime_payment_voucher_save_state.dart';

class BedtimePaymentVoucherSaveBloc
    extends Bloc<BedtimePaymentVoucherSaveEvent, BedtimePaymentVoucherSaveState> {
  final BedtimePaymentVoucherSaveRepository repository;

  BedtimePaymentVoucherSaveBloc(this.repository)
      : super(BedtimePaymentVoucherSaveInitial()) {
    on<BedtimePaymentVoucherSaveRequested>(_onSaveRequested);
  }

  Future<void> _onSaveRequested(
    BedtimePaymentVoucherSaveRequested event,
    Emitter<BedtimePaymentVoucherSaveState> emit,
  ) async {
    emit(BedtimePaymentVoucherSaving());

    try {
      final saveResponse = await repository.savePaymentVoucher(
        payload: event.payload,
      );
      emit(BedtimePaymentVoucherSaveSuccess(saveResponse));
    } catch (e) {
      emit(
        BedtimePaymentVoucherSaveFailure(
          e.toString().replaceFirst("Exception:", "").trim(),
        ),
      );
    }
  }
}
