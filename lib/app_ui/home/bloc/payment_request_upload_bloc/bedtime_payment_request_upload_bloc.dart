import 'package:bedtime_stories/app_ui/home/bloc/payment_request_upload_bloc/bedtime_payment_request_upload_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bedtime_payment_request_upload_event.dart';
import 'bedtime_payment_request_upload_state.dart';

class BedtimePaymentRequestUploadBloc extends Bloc<
    BedtimePaymentRequestUploadEvent, BedtimePaymentRequestUploadState> {
  final BedtimePaymentRequestUploadRepository repository;

  BedtimePaymentRequestUploadBloc(this.repository)
      : super(BedtimePaymentRequestUploadInitial()) {
    on<BedtimePaymentRequestUploadRequested>(_onUploadRequested);
  }

  Future<void> _onUploadRequested(
    BedtimePaymentRequestUploadRequested event,
    Emitter<BedtimePaymentRequestUploadState> emit,
  ) async {
    emit(BedtimePaymentRequestUploading(localId: event.localId, progress: 0));

    try {
      final uploadResponse = await repository.uploadAttachment(
        companyId: event.companyId,
        projectId: event.projectId,
        filePath: event.filePath,
        fileName: event.fileName,
        onSendProgress: (sent, total) {
          final resolvedTotal = total <= 0 ? 1 : total;
          final progress = (sent / resolvedTotal).clamp(0.0, 1.0);
          if (!isClosed) {
            emit(
              BedtimePaymentRequestUploading(
                localId: event.localId,
                progress: progress,
              ),
            );
          }
        },
      );

      emit(
        BedtimePaymentRequestUploadSuccess(
          localId: event.localId,
          response: uploadResponse,
        ),
      );
    } catch (e) {
      emit(
        BedtimePaymentRequestUploadFailure(
          localId: event.localId,
          message: e.toString().replaceFirst("Exception:", "").trim(),
        ),
      );
    }
  }
}
