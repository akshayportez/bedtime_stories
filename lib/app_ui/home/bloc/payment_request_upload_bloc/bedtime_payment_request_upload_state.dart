import 'package:bedtime_stories/app_ui/home/model/bedtime_payment_request_upload_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimePaymentRequestUploadState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentRequestUploadInitial extends BedtimePaymentRequestUploadState {}

class BedtimePaymentRequestUploading extends BedtimePaymentRequestUploadState {
  final String localId;
  final double progress;

  BedtimePaymentRequestUploading({
    required this.localId,
    required this.progress,
  });

  @override
  List<Object?> get props => [localId, progress];
}

class BedtimePaymentRequestUploadSuccess extends BedtimePaymentRequestUploadState {
  final String localId;
  final BedtimePaymentRequestUploadResponse response;

  BedtimePaymentRequestUploadSuccess({
    required this.localId,
    required this.response,
  });

  @override
  List<Object?> get props => [localId, response];
}

class BedtimePaymentRequestUploadFailure extends BedtimePaymentRequestUploadState {
  final String localId;
  final String message;

  BedtimePaymentRequestUploadFailure({
    required this.localId,
    required this.message,
  });

  @override
  List<Object?> get props => [localId, message];
}
