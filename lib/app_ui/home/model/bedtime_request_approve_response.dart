class BedtimeRequestApproveResponse {
  final int nFlag;
  final String cMessage;

  BedtimeRequestApproveResponse({
    required this.nFlag,
    required this.cMessage,
  });

  factory BedtimeRequestApproveResponse.fromJson(Map<String, dynamic> json) {
    return BedtimeRequestApproveResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
    );
  }
}
