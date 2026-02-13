import 'package:equatable/equatable.dart';

abstract class BedtimePaymentRequestReportEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentRequestReportLoadRequested
    extends BedtimePaymentRequestReportEvent {
  final int companyId;
  final String projectIds;
  final String status;
  final String dFrom;
  final String dTo;
  final String accountIds;
  final String categoryIds;
  final String sectionIds;
  final String userIds;

  BedtimePaymentRequestReportLoadRequested({
    required this.companyId,
    required this.projectIds,
    required this.status,
    required this.dFrom,
    required this.dTo,
    this.accountIds = "",
    this.categoryIds = "",
    this.sectionIds = "",
    this.userIds = "",
  });
}
