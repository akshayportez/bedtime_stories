import 'package:bedtime_stories/app_ui/home/model/bedtime_voucher_report_response.dart';
import 'package:equatable/equatable.dart';

abstract class BedtimeVoucherReportState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeVoucherReportInitial extends BedtimeVoucherReportState {}

class BedtimeVoucherReportLoading extends BedtimeVoucherReportState {}

class BedtimeVoucherReportLoaded extends BedtimeVoucherReportState {
  final List<BedtimeVoucherReportRow> rows;

  BedtimeVoucherReportLoaded(this.rows);

  @override
  List<Object?> get props => [rows];
}

class BedtimeVoucherReportFailure extends BedtimeVoucherReportState {
  final String message;

  BedtimeVoucherReportFailure(this.message);

  @override
  List<Object?> get props => [message];
}
