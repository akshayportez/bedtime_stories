import 'package:bedtime_stories/app_ui/home/model/bedtime_payment_request_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimePaymentRequestState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentRequestInitial extends BedtimePaymentRequestState {}

class BedtimePaymentRequestLoading extends BedtimePaymentRequestState {}

class BedtimePaymentRequestLoaded extends BedtimePaymentRequestState {
  final List<BedtimePaymentRequest> requests;

  BedtimePaymentRequestLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class BedtimePaymentRequestFailure extends BedtimePaymentRequestState {
  final String message;

  BedtimePaymentRequestFailure(this.message);

  @override
  List<Object?> get props => [message];
}
