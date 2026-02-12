import 'package:bedtime_stories/app_ui/home/model/bedtime_request_reject_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimeRequestRejectState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeRequestRejectInitial extends BedtimeRequestRejectState {}

class BedtimeRequestRejectLoading extends BedtimeRequestRejectState {}

class BedtimeRequestRejectSuccess extends BedtimeRequestRejectState {
  final BedtimeRequestRejectResponse response;

  BedtimeRequestRejectSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class BedtimeRequestRejectFailure extends BedtimeRequestRejectState {
  final String message;

  BedtimeRequestRejectFailure(this.message);

  @override
  List<Object?> get props => [message];
}
