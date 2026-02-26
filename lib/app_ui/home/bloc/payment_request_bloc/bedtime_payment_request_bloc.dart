import 'package:bedtime_stories/app_ui/home/bloc/payment_request_bloc/bedtime_payment_request_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_payment_request_event.dart';
import 'bedtime_payment_request_state.dart';

class BedtimePaymentRequestBloc
    extends Bloc<BedtimePaymentRequestEvent, BedtimePaymentRequestState> {
  final BedtimePaymentRequestRepository repository;

  BedtimePaymentRequestBloc(this.repository)
      : super(BedtimePaymentRequestInitial()) {
    on<BedtimePaymentRequestLoadRequested>(_onLoadRequests);
    on<BedtimePaymentRequestSearchRequested>(_onSearchRequests);
  }

  Future<void> _onLoadRequests(
    BedtimePaymentRequestLoadRequested event,
    Emitter<BedtimePaymentRequestState> emit,
  ) async {
    emit(BedtimePaymentRequestLoading());

    try {
      final requests = await repository.getPaymentRequests(
        companyId: event.companyId,
        projectId: event.projectId,
        userActionId: event.userActionId,
        search: event.search,
        statusFilter: event.statusFilter,
        dFrom: event.dFrom,
        dTo: event.dTo,
      );

      emit(BedtimePaymentRequestLoaded(requests));
    } catch (e) {
      emit(BedtimePaymentRequestFailure(
        e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }

  Future<void> _onSearchRequests(
    BedtimePaymentRequestSearchRequested event,
    Emitter<BedtimePaymentRequestState> emit,
  ) async {
    emit(BedtimePaymentRequestLoading());

    try {
      final requests = await repository.getPaymentRequests(
        companyId: event.companyId,
        projectId: event.projectId,
        userActionId: 0,
        search: event.search,
        statusFilter: event.statusFilter,
        dFrom: event.dFrom,
        dTo: event.dTo,
      );

      emit(BedtimePaymentRequestLoaded(requests));
    } catch (e) {
      emit(BedtimePaymentRequestFailure(
        e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }
}
