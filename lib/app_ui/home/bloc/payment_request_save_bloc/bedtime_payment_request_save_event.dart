import 'package:equatable/equatable.dart';

abstract class BedtimePaymentRequestSaveEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentRequestSaveRequested extends BedtimePaymentRequestSaveEvent {
  final Map<String, dynamic> payload;

  BedtimePaymentRequestSaveRequested({
    required this.payload,
  });

  @override
  List<Object?> get props => [payload];
}
