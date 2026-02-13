import 'package:bedtime_stories/app_ui/home/model/bedtime_payment_request_report_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimePaymentRequestReportState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentRequestReportInitial
    extends BedtimePaymentRequestReportState {}

class BedtimePaymentRequestReportLoading
    extends BedtimePaymentRequestReportState {}

class BedtimePaymentRequestReportLoaded
    extends BedtimePaymentRequestReportState {
  final List<BedtimePaymentRequestReportRow> rows;

  BedtimePaymentRequestReportLoaded(this.rows);

  @override
  List<Object?> get props => [rows];
}

class BedtimePaymentRequestReportFailure
    extends BedtimePaymentRequestReportState {
  final String message;

  BedtimePaymentRequestReportFailure(this.message);

  @override
  List<Object?> get props => [message];
}
