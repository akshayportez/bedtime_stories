import 'package:bedtime_stories/app_ui/home/model/bedtime_payment_request_detail_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimePaymentRequestDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentRequestDetailInitial
    extends BedtimePaymentRequestDetailState {}

class BedtimePaymentRequestDetailLoading
    extends BedtimePaymentRequestDetailState {}

class BedtimePaymentRequestDetailLoaded
    extends BedtimePaymentRequestDetailState {
  final BedtimePaymentRequestDetailResponse detail;

  BedtimePaymentRequestDetailLoaded(this.detail);

  @override
  List<Object?> get props => [detail];
}

class BedtimePaymentRequestDetailFailure
    extends BedtimePaymentRequestDetailState {
  final String message;

  BedtimePaymentRequestDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}
