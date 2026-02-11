import 'package:bedtime_stories/app_ui/home/bloc/get_tax_list_bloc/bedtime_get_tax_list_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_get_tax_list_event.dart';
import 'bedtime_get_tax_list_state.dart';

class BedtimeGetTaxListBloc
    extends Bloc<BedtimeGetTaxListEvent, BedtimeGetTaxListState> {
  final BedtimeGetTaxListRepository repository;

  BedtimeGetTaxListBloc(this.repository) : super(BedtimeGetTaxListInitial()) {
    on<BedtimeGetTaxListLoadRequested>(_onLoadTaxes);
  }

  Future<void> _onLoadTaxes(
    BedtimeGetTaxListLoadRequested event,
    Emitter<BedtimeGetTaxListState> emit,
  ) async {
    emit(BedtimeGetTaxListLoading());

    try {
      final taxes = await repository.getTaxes(companyId: event.companyId);
      emit(BedtimeGetTaxListLoaded(taxes));
    } catch (e) {
      emit(BedtimeGetTaxListFailure(
        e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }
}
