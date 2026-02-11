class BedtimePaymentRequestUploadResponse {
  final int nFlag;
  final String cMessage;
  final String cAttachment;

  BedtimePaymentRequestUploadResponse({
    required this.nFlag,
    required this.cMessage,
    required this.cAttachment,
  });

  factory BedtimePaymentRequestUploadResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return BedtimePaymentRequestUploadResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      cAttachment: json["cAttachment"] ?? "",
    );
  }
}
