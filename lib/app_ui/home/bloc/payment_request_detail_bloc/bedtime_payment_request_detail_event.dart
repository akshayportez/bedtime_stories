import 'package:equatable/equatable.dart';

abstract class BedtimePaymentRequestDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentRequestDetailLoadRequested
    extends BedtimePaymentRequestDetailEvent {
  final int companyId;
  final int payReqId;

  BedtimePaymentRequestDetailLoadRequested({
    required this.companyId,
    required this.payReqId,
  });
}
