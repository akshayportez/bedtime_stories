import 'package:equatable/equatable.dart';

abstract class BedtimeRequestApproveEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimeRequestApproveRequested extends BedtimeRequestApproveEvent {
  final int nPayReqId;
  final int nCompanyId;
  final int nUserActionId;
  final String cApprovalComment;

  BedtimeRequestApproveRequested({
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
