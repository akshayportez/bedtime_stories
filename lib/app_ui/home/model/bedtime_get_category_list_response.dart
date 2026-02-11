class BedtimeGetCategoryListResponse {
  final int nFlag;
  final String cMessage;
  final List<BedtimeGetCategoryList> data;

  BedtimeGetCategoryListResponse({
    required this.nFlag,
    required this.cMessage,
    required this.data,
  });

  factory BedtimeGetCategoryListResponse.fromJson(Map<String, dynamic> json) {
    return BedtimeGetCategoryListResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      data: (json["data"] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => BedtimeGetCategoryList.fromJson(item))
          .toList(),
    );
  }
}

class BedtimeGetCategoryList {
  final int nCategoryId;
  final String cCategoryName;
  final String cCategoryShName;
  final bool bActive;
  final String dCreatedDate;
  final String? dModifiedDate;

  BedtimeGetCategoryList({
    required this.nCategoryId,
    required this.cCategoryName,
    required this.cCategoryShName,
    required this.bActive,
    required this.dCreatedDate,
    required this.dModifiedDate,
  });

  factory BedtimeGetCategoryList.fromJson(Map<String, dynamic> json) {
    return BedtimeGetCategoryList(
      nCategoryId: json["nCategoryId"] ?? 0,
      cCategoryName: json["cCategoryName"] ?? "",
      cCategoryShName: json["cCategoryShName"] ?? "",
      bActive: json["bActive"] ?? false,
      dCreatedDate: json["dCreatedDate"] ?? "",
      dModifiedDate: json["dModifiedDate"],
    );
  }
}
