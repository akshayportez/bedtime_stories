import 'package:bedtime_stories/app_ui/home/model/bedtime_payment_voucher_detail_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimePaymentVoucherDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentVoucherDetailInitial
    extends BedtimePaymentVoucherDetailState {}

class BedtimePaymentVoucherDetailLoading
    extends BedtimePaymentVoucherDetailState {}

class BedtimePaymentVoucherDetailLoaded
    extends BedtimePaymentVoucherDetailState {
  final BedtimePaymentVoucherDetailResponse detail;

  BedtimePaymentVoucherDetailLoaded(this.detail);

  @override
  List<Object?> get props => [detail];
}

class BedtimePaymentVoucherDetailFailure
    extends BedtimePaymentVoucherDetailState {
  final String message;

  BedtimePaymentVoucherDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}
