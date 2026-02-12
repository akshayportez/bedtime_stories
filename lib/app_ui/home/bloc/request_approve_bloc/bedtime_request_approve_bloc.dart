import 'package:bedtime_stories/app_ui/home/bloc/request_approve_bloc/bedtime_request_approve_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_request_approve_event.dart';
import 'bedtime_request_approve_state.dart';

class BedtimeRequestApproveBloc
    extends Bloc<BedtimeRequestApproveEvent, BedtimeRequestApproveState> {
  final BedtimeRequestApproveRepository repository;

  BedtimeRequestApproveBloc(this.repository)
      : super(BedtimeRequestApproveInitial()) {
    on<BedtimeRequestApproveRequested>(_onApproveRequested);
  }

  Future<void> _onApproveRequested(
    BedtimeRequestApproveRequested event,
    Emitter<BedtimeRequestApproveState> emit,
  ) async {
    emit(BedtimeRequestApproveLoading());

    try {
      final response = await repository.approveRequest(
        payload: {
          "nPayReqId": event.nPayReqId,
          "nCompanyId": event.nCompanyId,
          "nUserActionId": event.nUserActionId,
          "cApprovalComment": event.cApprovalComment,
        },
      );
      emit(BedtimeRequestApproveSuccess(response));
    } catch (e) {
      emit(
        BedtimeRequestApproveFailure(
          e.toString().replaceFirst("Exception:", "").trim(),
        ),
      );
    }
  }
}
