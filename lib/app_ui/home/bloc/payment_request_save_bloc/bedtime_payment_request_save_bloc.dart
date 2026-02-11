import 'package:bedtime_stories/app_ui/home/bloc/payment_request_save_bloc/bedtime_payment_request_save_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_payment_request_save_event.dart';
import 'bedtime_payment_request_save_state.dart';

class BedtimePaymentRequestSaveBloc
    extends Bloc<BedtimePaymentRequestSaveEvent, BedtimePaymentRequestSaveState> {
  final BedtimePaymentRequestSaveRepository repository;

  BedtimePaymentRequestSaveBloc(this.repository)
      : super(BedtimePaymentRequestSaveInitial()) {
    on<BedtimePaymentRequestSaveRequested>(_onSaveRequested);
  }

  Future<void> _onSaveRequested(
    BedtimePaymentRequestSaveRequested event,
    Emitter<BedtimePaymentRequestSaveState> emit,
  ) async {
    emit(BedtimePaymentRequestSaving());

    try {
      final saveResponse = await repository.savePaymentRequest(
        payload: event.payload,
      );
      emit(BedtimePaymentRequestSaveSuccess(saveResponse));
    } catch (e) {
      emit(
        BedtimePaymentRequestSaveFailure(
          e.toString().replaceFirst("Exception:", "").trim(),
        ),
      );
    }
  }
}
