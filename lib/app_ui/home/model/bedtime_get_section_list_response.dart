class BedtimeGetSectionListResponse {
  final int nFlag;
  final String cMessage;
  final List<BedtimeGetSectionList> data;

  BedtimeGetSectionListResponse({
    required this.nFlag,
    required this.cMessage,
    required this.data,
  });

  factory BedtimeGetSectionListResponse.fromJson(Map<String, dynamic> json) {
    return BedtimeGetSectionListResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      data: (json["data"] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => BedtimeGetSectionList.fromJson(item))
          .toList(),
    );
  }
}

class BedtimeGetSectionList {
  final int nSectionId;
  final String cSectionName;
  final String cSectionShName;
  final bool bActive;
  final String dCreatedDate;
  final String? dModifiedDate;

  BedtimeGetSectionList({
    required this.nSectionId,
    required this.cSectionName,
    required this.cSectionShName,
    required this.bActive,
    required this.dCreatedDate,
    required this.dModifiedDate,
  });

  factory BedtimeGetSectionList.fromJson(Map<String, dynamic> json) {
    return BedtimeGetSectionList(
      nSectionId: json["nSectionId"] ?? 0,
      cSectionName: json["cSectionName"] ?? "",
      cSectionShName: json["cSectionShName"] ?? "",
      bActive: json["bActive"] ?? false,
      dCreatedDate: json["dCreatedDate"] ?? "",
      dModifiedDate: json["dModifiedDate"],
    );
  }
}
