class BedtimeGetBankListResponse {
  final int nFlag;
  final String cMessage;
  final List<BedtimeGetBankList> data;

  BedtimeGetBankListResponse({
    required this.nFlag,
    required this.cMessage,
    required this.data,
  });

  factory BedtimeGetBankListResponse.fromJson(Map<String, dynamic> json) {
    return BedtimeGetBankListResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      data: (json["data"] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => BedtimeGetBankList.fromJson(item))
          .toList(),
    );
  }
}

class BedtimeGetBankList {
  final int nBankId;
  final String cBankName;
  final String cBankShName;
  final bool bActive;
  final String dCreatedDate;
  final String? dModifiedDate;

  BedtimeGetBankList({
    required this.nBankId,
    required this.cBankName,
    required this.cBankShName,
    required this.bActive,
    required this.dCreatedDate,
    required this.dModifiedDate,
  });

  factory BedtimeGetBankList.fromJson(Map<String, dynamic> json) {
    return BedtimeGetBankList(
      nBankId: json["nBankId"] ?? 0,
      cBankName: json["cBankName"] ?? "",
      cBankShName: json["cBankShName"] ?? "",
      bActive: json["bActive"] ?? false,
      dCreatedDate: json["dCreatedDate"] ?? "",
      dModifiedDate: json["dModifiedDate"],
    );
  }
}
