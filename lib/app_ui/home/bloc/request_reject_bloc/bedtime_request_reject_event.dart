import 'package:equatable/equatable.dart';

abstract class BedtimeRequestRejectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeRequestRejectRequested extends BedtimeRequestRejectEvent {
  final int nPayReqId;
  final int nCompanyId;
  final int nUserActionId;
  final String cApprovalComment;

  BedtimeRequestRejectRequested({
    required this.nPayReqId,
    required this.nCompanyId,
    required this.nUserActionId,
    required this.cApprovalComment,
  });

  @override
  List<Object?> get props => [
        nPayReqId,
        nCompanyId,
        nUserActionId,
        cApprovalComment,
      ];
}
