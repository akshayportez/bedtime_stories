import 'package:equatable/equatable.dart';

abstract class BedtimeVoucherReportEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeVoucherReportLoadRequested extends BedtimeVoucherReportEvent {
  final int companyId;
  final String projectIds;
  final String dFrom;
  final String dTo;
  final String accountIds;
  final String categoryIds;
  final String sectionIds;
  final String userIds;
  final String payModes;

  BedtimeVoucherReportLoadRequested({
    required this.companyId,
    required this.projectIds,
    required this.dFrom,
    required this.dTo,
    this.accountIds = "",
    this.categoryIds = "",
    this.sectionIds = "",
    this.userIds = "",
    this.payModes = "",
  });
}
