import 'package:bedtime_stories/app_ui/home/bloc/payment_voucher_pdf_bloc/bedtime_payment_voucher_pdf_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_payment_voucher_pdf_event.dart';
import 'bedtime_payment_voucher_pdf_state.dart';

class BedtimePaymentVoucherPdfBloc
    extends Bloc<BedtimePaymentVoucherPdfEvent, BedtimePaymentVoucherPdfState> {
  final BedtimePaymentVoucherPdfRepository repository;

  BedtimePaymentVoucherPdfBloc(this.repository)
      : super(BedtimePaymentVoucherPdfInitial()) {
    on<BedtimePaymentVoucherPdfLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    BedtimePaymentVoucherPdfLoadRequested event,
    Emitter<BedtimePaymentVoucherPdfState> emit,
  ) async {
    emit(BedtimePaymentVoucherPdfLoading(event.payReqId));

    try {
      final pdfBytes = await repository.getPaymentVoucherPdf(
        companyId: event.companyId,
        payReqId: event.payReqId,
        userActionId: event.userActionId,
      );

      emit(BedtimePaymentVoucherPdfLoaded(
        payReqId: event.payReqId,
        pdfBytes: pdfBytes,
      ));
    } catch (e) {
      emit(BedtimePaymentVoucherPdfFailure(
        payReqId: event.payReqId,
        message: e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }
}
