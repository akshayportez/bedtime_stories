class BedtimeGetAccountsListResponse {
  final int nFlag;
  final String cMessage;
  final List<BedtimeGetAccountsList> data;

  BedtimeGetAccountsListResponse({
    required this.nFlag,
    required this.cMessage,
    required this.data,
  });

  factory BedtimeGetAccountsListResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return BedtimeGetAccountsListResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      data: (json["data"] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => BedtimeGetAccountsList.fromJson(item))
          .toList(),
    );
  }
}

class BedtimeGetAccountsList {
  final int nAccountId;
  final String cAccountName;
  final String cAccountShName;
  final String cPAN;
  final String cGST;
  final bool bTDS;
  final double nTDSPercent;
  final bool bTaxable;
  final bool bActive;
  final String dCreatedDate;
  final String? dModifiedDate;
  final List<BedtimeGetAccountsListTaxDetail> taxDetails;

  BedtimeGetAccountsList({
    required this.nAccountId,
    required this.cAccountName,
    required this.cAccountShName,
    required this.cPAN,
    required this.cGST,
    required this.bTDS,
    required this.nTDSPercent,
    required this.bTaxable,
    required this.bActive,
    required this.dCreatedDate,
    required this.dModifiedDate,
    required this.taxDetails,
  });

  factory BedtimeGetAccountsList.fromJson(Map<String, dynamic> json) {
    return BedtimeGetAccountsList(
      nAccountId: json["nAccountId"] ?? 0,
      cAccountName: json["cAccountName"] ?? "",
      cAccountShName: json["cAccountShName"] ?? "",
      cPAN: json["cPAN"] ?? "",
      cGST: json["cGST"] ?? "",
      bTDS: json["bTDS"] ?? false,
      nTDSPercent: (json["nTDSPercent"] ?? 0).toDouble(),
      bTaxable: json["bTaxable"] ?? false,
      bActive: json["bActive"] ?? false,
      dCreatedDate: json["dCreatedDate"] ?? "",
      dModifiedDate: json["dModifiedDate"],
      taxDetails: (json["TaxDetails"] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => BedtimeGetAccountsListTaxDetail.fromJson(item))
          .toList(),
    );
  }
}

class BedtimeGetAccountsListTaxDetail {
  final Map<String, dynamic> raw;

  BedtimeGetAccountsListTaxDetail({required this.raw});

  factory BedtimeGetAccountsListTaxDetail.fromJson(
    Map<String, dynamic> json,
  ) {
    return BedtimeGetAccountsListTaxDetail(raw: json);
  }
}

