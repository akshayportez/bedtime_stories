import 'package:equatable/equatable.dart';

abstract class BedtimePaymentVoucherDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentVoucherDetailLoadRequested
    extends BedtimePaymentVoucherDetailEvent {
  final int companyId;
  final int payReqId;

  BedtimePaymentVoucherDetailLoadRequested({
    required this.companyId,
    required this.payReqId,
  });
}
