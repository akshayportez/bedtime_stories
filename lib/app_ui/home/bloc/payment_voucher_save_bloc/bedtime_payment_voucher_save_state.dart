import 'package:bedtime_stories/app_ui/home/model/bedtime_payment_voucher_save_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimePaymentVoucherSaveState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentVoucherSaveInitial extends BedtimePaymentVoucherSaveState {}

class BedtimePaymentVoucherSaving extends BedtimePaymentVoucherSaveState {}

class BedtimePaymentVoucherSaveSuccess extends BedtimePaymentVoucherSaveState {
  final BedtimePaymentVoucherSaveResponse response;

  BedtimePaymentVoucherSaveSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class BedtimePaymentVoucherSaveFailure extends BedtimePaymentVoucherSaveState {
  final String message;

  BedtimePaymentVoucherSaveFailure(this.message);

  @override
  List<Object?> get props => [message];
}
