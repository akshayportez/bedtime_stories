import 'package:equatable/equatable.dart';

abstract class BedtimePaymentVoucherSaveEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentVoucherSaveRequested
    extends BedtimePaymentVoucherSaveEvent {
  final Map<String, dynamic> payload;

  BedtimePaymentVoucherSaveRequested({
    required this.payload,
  });

  @override
  List<Object?> get props => [payload];
}
