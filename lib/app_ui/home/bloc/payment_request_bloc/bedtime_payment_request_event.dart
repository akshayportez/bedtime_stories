import 'package:equatable/equatable.dart';

abstract class BedtimePaymentRequestEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentRequestLoadRequested extends BedtimePaymentRequestEvent {
  final int companyId;
  final int projectId;
  final int userActionId;
  final String search;
  final String statusFilter;
  final String cStatus;
  final String dFrom;
  final String dTo;

  BedtimePaymentRequestLoadRequested({
    required this.companyId,
    required this.projectId,
    required this.userActionId,
    this.search = "",
    this.statusFilter = "",
    this.cStatus = "",
    this.dFrom = "",
    this.dTo = "",
  });
}

class BedtimePaymentRequestSearchRequested extends BedtimePaymentRequestEvent {
  final int companyId;
  final int projectId;
  final int userActionId;
  final String search;
  final String statusFilter;
  final String cStatus;
  final String dFrom;
  final String dTo;

  BedtimePaymentRequestSearchRequested({
    required this.companyId,
    required this.projectId,
    required this.userActionId,
    required this.search,
    this.statusFilter = "",
    this.cStatus = "",
    this.dFrom = "",
    this.dTo = "",
  });
}
