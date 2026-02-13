import 'package:equatable/equatable.dart';

abstract class BedtimePaymentVoucherEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentVoucherLoadRequested extends BedtimePaymentVoucherEvent {
  final int companyId;
  final int projectId;
  final int userActionId;
  final String search;
  final String statusFilter;
  final String dFrom;
  final String dTo;

  BedtimePaymentVoucherLoadRequested({
    required this.companyId,
    required this.projectId,
    required this.userActionId,
    this.search = "",
    this.statusFilter = "",
    this.dFrom = "",
    this.dTo = "",
  });
}

class BedtimePaymentVoucherSearchRequested extends BedtimePaymentVoucherEvent {
  final int companyId;
  final int projectId;
  final int userActionId;
  final String search;
  final String statusFilter;
  final String dFrom;
  final String dTo;

  BedtimePaymentVoucherSearchRequested({
    required this.companyId,
    required this.projectId,
    required this.userActionId,
    required this.search,
    this.statusFilter = "",
    this.dFrom = "",
    this.dTo = "",
  });
}
