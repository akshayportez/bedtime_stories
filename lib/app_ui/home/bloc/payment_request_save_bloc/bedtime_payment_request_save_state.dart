import 'package:bedtime_stories/app_ui/home/model/bedtime_payment_request_save_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimePaymentRequestSaveState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentRequestSaveInitial extends BedtimePaymentRequestSaveState {}

class BedtimePaymentRequestSaving extends BedtimePaymentRequestSaveState {}

class BedtimePaymentRequestSaveSuccess extends BedtimePaymentRequestSaveState {
  final BedtimePaymentRequestSaveResponse response;

  BedtimePaymentRequestSaveSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class BedtimePaymentRequestSaveFailure extends BedtimePaymentRequestSaveState {
  final String message;

  BedtimePaymentRequestSaveFailure(this.message);

  @override
  List<Object?> get props => [message];
}
