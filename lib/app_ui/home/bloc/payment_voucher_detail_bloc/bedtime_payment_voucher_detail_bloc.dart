import 'package:bedtime_stories/app_ui/home/bloc/payment_voucher_detail_bloc/bedtime_payment_voucher_detail_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_payment_voucher_detail_event.dart';
import 'bedtime_payment_voucher_detail_state.dart';

class BedtimePaymentVoucherDetailBloc extends Bloc<
    BedtimePaymentVoucherDetailEvent, BedtimePaymentVoucherDetailState> {
  final BedtimePaymentVoucherDetailRepository repository;

  BedtimePaymentVoucherDetailBloc(this.repository)
      : super(BedtimePaymentVoucherDetailInitial()) {
    on<BedtimePaymentVoucherDetailLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    BedtimePaymentVoucherDetailLoadRequested event,
    Emitter<BedtimePaymentVoucherDetailState> emit,
  ) async {
    emit(BedtimePaymentVoucherDetailLoading());

    try {
      final detail = await repository.getPaymentVoucherDetail(
        companyId: event.companyId,
        payReqId: event.payReqId,
      );

      emit(BedtimePaymentVoucherDetailLoaded(detail));
    } catch (e) {
      emit(BedtimePaymentVoucherDetailFailure(
        e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }
}
