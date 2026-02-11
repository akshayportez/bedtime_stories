import 'package:bedtime_stories/app_ui/home/bloc/get_section_list_bloc/bedtime_get_section_list_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_get_section_list_event.dart';
import 'bedtime_get_section_list_state.dart';

class BedtimeGetSectionListBloc
    extends Bloc<BedtimeGetSectionListEvent, BedtimeGetSectionListState> {
  final BedtimeGetSectionListRepository repository;

  BedtimeGetSectionListBloc(this.repository)
      : super(BedtimeGetSectionListInitial()) {
    on<BedtimeGetSectionListLoadRequested>(_onLoadSections);
  }

  Future<void> _onLoadSections(
    BedtimeGetSectionListLoadRequested event,
    Emitter<BedtimeGetSectionListState> emit,
  ) async {
    emit(BedtimeGetSectionListLoading());

    try {
      final sections = await repository.getSections(companyId: event.companyId);
      emit(BedtimeGetSectionListLoaded(sections));
    } catch (e) {
      emit(BedtimeGetSectionListFailure(
        e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }
}
