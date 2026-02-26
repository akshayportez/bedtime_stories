import 'package:equatable/equatable.dart';

abstract class BedtimePaymentVoucherPdfEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentVoucherPdfLoadRequested
    extends BedtimePaymentVoucherPdfEvent {
  final int companyId;
  final int payReqId;
  final int userActionId;

  BedtimePaymentVoucherPdfLoadRequested({
    required this.companyId,
    required this.payReqId,
    this.userActionId = 0,
  });

  @override
  List<Object?> get props => [companyId, payReqId, userActionId];
}
