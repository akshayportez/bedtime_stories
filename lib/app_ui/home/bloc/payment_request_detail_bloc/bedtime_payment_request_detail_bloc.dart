import 'package:bedtime_stories/app_ui/home/bloc/payment_request_detail_bloc/bedtime_payment_request_detail_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_payment_request_detail_event.dart';
import 'bedtime_payment_request_detail_state.dart';

class BedtimePaymentRequestDetailBloc extends Bloc<
    BedtimePaymentRequestDetailEvent, BedtimePaymentRequestDetailState> {
  final BedtimePaymentRequestDetailRepository repository;

  BedtimePaymentRequestDetailBloc(this.repository)
      : super(BedtimePaymentRequestDetailInitial()) {
    on<BedtimePaymentRequestDetailLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    BedtimePaymentRequestDetailLoadRequested event,
    Emitter<BedtimePaymentRequestDetailState> emit,
  ) async {
    emit(BedtimePaymentRequestDetailLoading());

    try {
      final detail = await repository.getPaymentRequestDetail(
        companyId: event.companyId,
        payReqId: event.payReqId,
      );

      emit(BedtimePaymentRequestDetailLoaded(detail));
    } catch (e) {
      emit(BedtimePaymentRequestDetailFailure(
        e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }
}
