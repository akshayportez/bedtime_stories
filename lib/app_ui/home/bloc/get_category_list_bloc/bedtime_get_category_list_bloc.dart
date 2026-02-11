import 'package:bedtime_stories/app_ui/home/bloc/get_category_list_bloc/bedtime_get_category_list_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_get_category_list_event.dart';
import 'bedtime_get_category_list_state.dart';

class BedtimeGetCategoryListBloc
    extends Bloc<BedtimeGetCategoryListEvent, BedtimeGetCategoryListState> {
  final BedtimeGetCategoryListRepository repository;

  BedtimeGetCategoryListBloc(this.repository)
      : super(BedtimeGetCategoryListInitial()) {
    on<BedtimeGetCategoryListLoadRequested>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(
    BedtimeGetCategoryListLoadRequested event,
    Emitter<BedtimeGetCategoryListState> emit,
  ) async {
    emit(BedtimeGetCategoryListLoading());

    try {
      final categories = await repository.getCategories(
        companyId: event.companyId,
      );
      emit(BedtimeGetCategoryListLoaded(categories));
    } catch (e) {
      emit(BedtimeGetCategoryListFailure(
        e.toString().replaceFirst("Exception:", "").trim(),
      ));
    }
  }
}
