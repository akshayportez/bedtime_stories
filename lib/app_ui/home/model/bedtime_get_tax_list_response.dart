class BedtimeGetTaxListResponse {
  final int nFlag;
  final String cMessage;
  final List<BedtimeGetTaxList> data;

  BedtimeGetTaxListResponse({
    required this.nFlag,
    required this.cMessage,
    required this.data,
  });

  factory BedtimeGetTaxListResponse.fromJson(Map<String, dynamic> json) {
    return BedtimeGetTaxListResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      data: (json["data"] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => BedtimeGetTaxList.fromJson(item))
          .toList(),
    );
  }
}

class BedtimeGetTaxList {
  final int nTaxId;
  final String cTaxName;
  final String cTaxShName;
  final bool bActive;
  final String dCreatedDate;
  final String? dModifiedDate;

  BedtimeGetTaxList({
    required this.nTaxId,
    required this.cTaxName,
    required this.cTaxShName,
    required this.bActive,
    required this.dCreatedDate,
    required this.dModifiedDate,
  });

  factory BedtimeGetTaxList.fromJson(Map<String, dynamic> json) {
    return BedtimeGetTaxList(
      nTaxId: json["nTaxId"] ?? 0,
      cTaxName: json["cTaxName"] ?? "",
      cTaxShName: json["cTaxShName"] ?? "",
      bActive: json["bActive"] ?? false,
      dCreatedDate: json["dCreatedDate"] ?? "",
      dModifiedDate: json["dModifiedDate"],
    );
  }
}
