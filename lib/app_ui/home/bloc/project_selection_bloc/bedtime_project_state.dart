import 'package:bedtime_stories/app_ui/home/model/bedtime_project_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimeProjectState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeProjectInitial extends BedtimeProjectState {}

class BedtimeProjectLoading extends BedtimeProjectState {}

class BedtimeProjectLoaded extends BedtimeProjectState {
  final List<BedtimeProject> projects;

  BedtimeProjectLoaded(this.projects);

  @override
  List<Object?> get props => [projects];
}

class BedtimeProjectFailure extends BedtimeProjectState {
  final String message;

  BedtimeProjectFailure(this.message);

  @override
  List<Object?> get props => [message];
}
