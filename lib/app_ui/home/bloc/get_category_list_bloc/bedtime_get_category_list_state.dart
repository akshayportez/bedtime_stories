import 'package:bedtime_stories/app_ui/home/model/bedtime_get_category_list_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimeGetCategoryListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeGetCategoryListInitial extends BedtimeGetCategoryListState {}

class BedtimeGetCategoryListLoading extends BedtimeGetCategoryListState {}

class BedtimeGetCategoryListLoaded extends BedtimeGetCategoryListState {
  final List<BedtimeGetCategoryList> categories;

  BedtimeGetCategoryListLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class BedtimeGetCategoryListFailure extends BedtimeGetCategoryListState {
  final String message;

  BedtimeGetCategoryListFailure(this.message);

  @override
  List<Object?> get props => [message];
}
