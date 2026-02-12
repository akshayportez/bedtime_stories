import 'package:bedtime_stories/app_ui/home/bloc/get_bank_list_bloc/bedtime_get_bank_list_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_get_bank_list_event.dart';
import 'bedtime_get_bank_list_state.dart';

class BedtimeGetBankListBloc
    extends Bloc<BedtimeGetBankListEvent, BedtimeGetBankListState> {
  final BedtimeGetBankListRepository repository;

  BedtimeGetBankListBloc(this.repository) : super(BedtimeGetBankListInitial()) {
    on<BedtimeGetBankListLoadRequested>(_onLoadBanks);
  }

  Future<void> _onLoadBanks(
    BedtimeGetBankListLoadRequested event,
    Emitter<BedtimeGetBankListState> emit,
  ) async {
    emit(BedtimeGetBankListLoading());

    try {
      final banks = await repository.getBanks(companyId: event.companyId);
      emit(BedtimeGetBankListLoaded(banks));
    } catch (e) {
      emit(
        BedtimeGetBankListFailure(
          e.toString().replaceFirst("Exception:", "").trim(),
        ),
      );
    }
  }
}
