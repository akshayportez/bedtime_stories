import 'package:equatable/equatable.dart';

abstract class BedtimePaymentRequestUploadEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BedtimePaymentRequestUploadRequested
    extends BedtimePaymentRequestUploadEvent {
  final int companyId;
  final int projectId;
  final String localId;
  final String filePath;
  final String fileName;

  BedtimePaymentRequestUploadRequested({
    required this.companyId,
    required this.projectId,
    required this.localId,
    required this.filePath,
    required this.fileName,
  });

  @override
  List<Object?> get props => [
        companyId,
        projectId,
        localId,
        filePath,
        fileName,
      ];
}
