import 'package:bedtime_stories/app_ui/home/model/bedtime_payment_voucher_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimePaymentVoucherState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentVoucherInitial extends BedtimePaymentVoucherState {}

class BedtimePaymentVoucherLoading extends BedtimePaymentVoucherState {}

class BedtimePaymentVoucherLoaded extends BedtimePaymentVoucherState {
  final List<BedtimePaymentVoucher> vouchers;

  BedtimePaymentVoucherLoaded(this.vouchers);

  @override
  List<Object?> get props => [vouchers];
}

class BedtimePaymentVoucherFailure extends BedtimePaymentVoucherState {
  final String message;

  BedtimePaymentVoucherFailure(this.message);

  @override
  List<Object?> get props => [message];
}
