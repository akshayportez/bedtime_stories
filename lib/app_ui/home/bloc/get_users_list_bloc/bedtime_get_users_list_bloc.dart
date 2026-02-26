import 'package:bedtime_stories/app_ui/home/bloc/get_users_list_bloc/bedtime_get_users_list_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_get_users_list_event.dart';
import 'bedtime_get_users_list_state.dart';

class BedtimeGetUsersListBloc
    extends Bloc<BedtimeGetUsersListEvent, BedtimeGetUsersListState> {
  final BedtimeGetUsersListRepository repository;

  BedtimeGetUsersListBloc(this.repository) : super(BedtimeGetUsersListInitial()) {
    on<BedtimeGetUsersListLoadRequested>(_onLoadUsers);
  }

  Future<void> _onLoadUsers(
    BedtimeGetUsersListLoadRequested event,
    Emitter<BedtimeGetUsersListState> emit,
  ) async {
    emit(BedtimeGetUsersListLoading());

    try {
      final users = await repository.getUsers(
        companyId: event.companyId,
        search: event.search,
      );
      emit(BedtimeGetUsersListLoaded(users));
    } catch (e) {
      emit(BedtimeGetUsersListFailure(
        e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }
}
