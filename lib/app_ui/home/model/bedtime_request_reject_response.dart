class BedtimeRequestRejectResponse {
  final int nFlag;
  final String cMessage;
  final int nPayReqId;

  BedtimeRequestRejectResponse({
    required this.nFlag,
    required this.cMessage,
    required this.nPayReqId,
  });

  factory BedtimeRequestRejectResponse.fromJson(Map<String, dynamic> json) {
    final value = json["nPayReqId"];
    final payReqId = value is int
        ? value
        : int.tryParse(value?.toString() ?? "") ?? 0;

    return BedtimeRequestRejectResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      nPayReqId: payReqId,
    );
  }
}
