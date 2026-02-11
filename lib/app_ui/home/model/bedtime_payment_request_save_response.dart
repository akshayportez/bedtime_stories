class BedtimePaymentRequestSaveResponse {
  final int nFlag;
  final String cMessage;
  final int nPayReqId;

  BedtimePaymentRequestSaveResponse({
    required this.nFlag,
    required this.cMessage,
    required this.nPayReqId,
  });

  factory BedtimePaymentRequestSaveResponse.fromJson(Map<String, dynamic> json) {
    final dynamic data = json["data"];
    int resolvedPayReqId = 0;
    if (data is Map<String, dynamic>) {
      final value = data["nPayReqId"];
      if (value is int) {
        resolvedPayReqId = value;
      } else {
        resolvedPayReqId = int.tryParse(value?.toString() ?? "") ?? 0;
      }
    }

    return BedtimePaymentRequestSaveResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      nPayReqId: resolvedPayReqId,
    );
  }
}
