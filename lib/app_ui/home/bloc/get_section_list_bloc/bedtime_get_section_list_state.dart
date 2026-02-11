import 'package:bedtime_stories/app_ui/home/model/bedtime_get_section_list_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimeGetSectionListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeGetSectionListInitial extends BedtimeGetSectionListState {}

class BedtimeGetSectionListLoading extends BedtimeGetSectionListState {}

class BedtimeGetSectionListLoaded extends BedtimeGetSectionListState {
  final List<BedtimeGetSectionList> sections;

  BedtimeGetSectionListLoaded(this.sections);

  @override
  List<Object?> get props => [sections];
}

class BedtimeGetSectionListFailure extends BedtimeGetSectionListState {
  final String message;

  BedtimeGetSectionListFailure(this.message);

  @override
  List<Object?> get props => [message];
}
