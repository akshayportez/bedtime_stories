import 'package:bedtime_stories/app_ui/home/model/bedtime_request_approve_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimeRequestApproveState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeRequestApproveInitial extends BedtimeRequestApproveState {}

class BedtimeRequestApproveLoading extends BedtimeRequestApproveState {}

class BedtimeRequestApproveSuccess extends BedtimeRequestApproveState {
  final BedtimeRequestApproveResponse response;

  BedtimeRequestApproveSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class BedtimeRequestApproveFailure extends BedtimeRequestApproveState {
  final String message;

  BedtimeRequestApproveFailure(this.message);

  @override
  List<Object?> get props => [message];
}
