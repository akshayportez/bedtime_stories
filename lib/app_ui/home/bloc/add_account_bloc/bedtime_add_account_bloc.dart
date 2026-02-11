import 'package:bedtime_stories/app_ui/home/bloc/add_account_bloc/bedtime_add_account_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_add_account_event.dart';
import 'bedtime_add_account_state.dart';

class BedtimeAddAccountBloc
    extends Bloc<BedtimeAddAccountEvent, BedtimeAddAccountState> {
  final BedtimeAddAccountRepository repository;

  BedtimeAddAccountBloc(this.repository) : super(BedtimeAddAccountInitial()) {
    on<BedtimeAddAccountSaveRequested>(_onSaveRequested);
  }

  Future<void> _onSaveRequested(
    BedtimeAddAccountSaveRequested event,
    Emitter<BedtimeAddAccountState> emit,
  ) async {
    emit(BedtimeAddAccountSaving());

    try {
      final response = await repository.saveAccount(payload: event.payload);
      emit(BedtimeAddAccountSaveSuccess(response));
    } catch (e) {
      emit(
        BedtimeAddAccountSaveFailure(
          e.toString().replaceFirst("Exception:", "").trim(),
        ),
      );
    }
  }
}
