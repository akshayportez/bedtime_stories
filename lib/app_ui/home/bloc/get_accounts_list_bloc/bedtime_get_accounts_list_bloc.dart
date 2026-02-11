import 'package:bedtime_stories/app_ui/home/bloc/get_accounts_list_bloc/bedtime_get_accounts_list_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_get_accounts_list_event.dart';
import 'bedtime_get_accounts_list_state.dart';

class BedtimeGetAccountsListBloc extends Bloc<
    BedtimeGetAccountsListEvent, BedtimeGetAccountsListState> {
  final BedtimeGetAccountsListRepository repository;

  BedtimeGetAccountsListBloc(this.repository)
      : super(BedtimeGetAccountsListInitial()) {
    on<BedtimeGetAccountsListLoadRequested>(_onLoadAccounts);
  }

  Future<void> _onLoadAccounts(
    BedtimeGetAccountsListLoadRequested event,
    Emitter<BedtimeGetAccountsListState> emit,
  ) async {
    emit(BedtimeGetAccountsListLoading());

    try {
      final accounts = await repository.getAccounts(companyId: event.companyId);
      emit(BedtimeGetAccountsListLoaded(accounts));
    } catch (e) {
      emit(BedtimeGetAccountsListFailure(
        e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }
}

