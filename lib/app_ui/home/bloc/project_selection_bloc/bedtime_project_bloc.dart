import 'package:bedtime_stories/app_ui/home/bloc/project_selection_bloc/bedtime_project_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';  
import 'bedtime_project_event.dart';
import 'bedtime_project_state.dart';

class BedtimeProjectBloc
    extends Bloc<BedtimeProjectEvent, BedtimeProjectState> {
  final BedtimeProjectRepository repository;

  BedtimeProjectBloc(this.repository) : super(BedtimeProjectInitial()) {
    on<BedtimeProjectLoadRequested>(_onLoadProjects);
    on<BedtimeProjectSearchRequested>(_onSearchProjects);
  }

  Future<void> _onLoadProjects(
    BedtimeProjectLoadRequested event,
    Emitter<BedtimeProjectState> emit,
  ) async {
    emit(BedtimeProjectLoading());

    try {
      final projects = await repository.getProjects(
        companyId: event.companyId,
        userId: event.userId,
        search: "",
      );

      emit(BedtimeProjectLoaded(projects));
    } catch (e) {
      emit(BedtimeProjectFailure(
        e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }

  Future<void> _onSearchProjects(
    BedtimeProjectSearchRequested event,
    Emitter<BedtimeProjectState> emit,
  ) async {
    emit(BedtimeProjectLoading());

    try {
      final projects = await repository.getProjects(
        companyId: event.companyId,
        userId: event.userId,
        search: event.search,
      );

      emit(BedtimeProjectLoaded(projects));
    } catch (e) {
      emit(BedtimeProjectFailure(
        e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }
}
