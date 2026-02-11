class BedtimeAddAccountResponse {
  final int nFlag;
  final String cMessage;
  final int nAccountId;

  BedtimeAddAccountResponse({
    required this.nFlag,
    required this.cMessage,
    required this.nAccountId,
  });

  factory BedtimeAddAccountResponse.fromJson(Map<String, dynamic> json) {
    return BedtimeAddAccountResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      nAccountId: json["nAccountId"] ?? 0,
    );
  }
}
