import 'dart:typed_data';

import 'package:equatable/equatable.dart';

abstract class BedtimePaymentVoucherPdfState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentVoucherPdfInitial extends BedtimePaymentVoucherPdfState {}

class BedtimePaymentVoucherPdfLoading extends BedtimePaymentVoucherPdfState {
  final int payReqId;

  BedtimePaymentVoucherPdfLoading(this.payReqId);

  @override
  List<Object?> get props => [payReqId];
}

class BedtimePaymentVoucherPdfLoaded extends BedtimePaymentVoucherPdfState {
  final int payReqId;
  final Uint8List pdfBytes;

  BedtimePaymentVoucherPdfLoaded({
    required this.payReqId,
    required this.pdfBytes,
  });

  @override
  List<Object?> get props => [payReqId, pdfBytes.lengthInBytes];
}

class BedtimePaymentVoucherPdfFailure extends BedtimePaymentVoucherPdfState {
  final int payReqId;
  final String message;

  BedtimePaymentVoucherPdfFailure({
    required this.payReqId,
    required this.message,
  });

  @override
  List<Object?> get props => [payReqId, message];
}
