part of 'package:bedtime_stories/utils/lib_files.dart';

class EditRequestPage extends StatelessWidget {
  final BedtimePaymentRequest request;
  final BedtimePaymentRequestDetail detail;
  final List<BedtimePaymentRequestTax> taxes;

  const EditRequestPage({
    super.key,
    required this.request,
    required this.detail,
    required this.taxes,
  });

  @override
  Widget build(BuildContext context) {
    return CreateRequestPage(
      isEditMode: true,
      initialRequest: request,
      initialDetail: detail,
      initialTaxes: taxes,
    );
  }
}
