import 'package:bedtime_stories/app_ui/home/bloc/request_reject_bloc/bedtime_request_reject_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_request_reject_event.dart';
import 'bedtime_request_reject_state.dart';

class BedtimeRequestRejectBloc
    extends Bloc<BedtimeRequestRejectEvent, BedtimeRequestRejectState> {
  final BedtimeRequestRejectRepository repository;

  BedtimeRequestRejectBloc(this.repository)
      : super(BedtimeRequestRejectInitial()) {
    on<BedtimeRequestRejectRequested>(_onRejectRequested);
  }

  Future<void> _onRejectRequested(
    BedtimeRequestRejectRequested event,
    Emitter<BedtimeRequestRejectState> emit,
  ) async {
    emit(BedtimeRequestRejectLoading());

    try {
      final response = await repository.rejectRequest(
        payload: {
          "nPayReqId": event.nPayReqId,
          "nCompanyId": event.nCompanyId,
          "nUserActionId": event.nUserActionId,
          "cApprovalComment": event.cApprovalComment,
        },
      );
      emit(BedtimeRequestRejectSuccess(response));
    } catch (e) {
      emit(
        BedtimeRequestRejectFailure(
          e.toString().replaceFirst("Exception:", "").trim(),
        ),
      );
    }
  }
}
