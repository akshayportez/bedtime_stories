class BedtimePaymentRequestReportResponse {
  final int nFlag;
  final String cMessage;
  final List<BedtimePaymentRequestReportRow> data;

  BedtimePaymentRequestReportResponse({
    required this.nFlag,
    required this.cMessage,
    required this.data,
  });

  factory BedtimePaymentRequestReportResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return BedtimePaymentRequestReportResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      data: (json["data"] as List? ?? const [])
          .map(
            (e) => BedtimePaymentRequestReportRow.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }
}

class BedtimePaymentRequestReportRow {
  final int nPayReqId;
  final String cRequestNo;
  final String dDate;
  final String dRequestDateTime;
  final String cRequestDateTime;
  final String cAccountName;
  final String cCategoryName;
  final String cSectionName;
  final String cStatus;
  final double nReqAmount;
  final double nTDS;
  final double nTax;
  final double nPayable;
  final int nUserId;
  final String cUserName;

  BedtimePaymentRequestReportRow({
    required this.nPayReqId,
    required this.cRequestNo,
    required this.dDate,
    required this.dRequestDateTime,
    required this.cRequestDateTime,
    required this.cAccountName,
    required this.cCategoryName,
    required this.cSectionName,
    required this.cStatus,
    required this.nReqAmount,
    required this.nTDS,
    required this.nTax,
    required this.nPayable,
    required this.nUserId,
    required this.cUserName,
  });

  factory BedtimePaymentRequestReportRow.fromJson(Map<String, dynamic> json) {
    return BedtimePaymentRequestReportRow(
      nPayReqId: json["nPayReqId"] ?? 0,
      cRequestNo: json["cRequestNo"] ?? "",
      dDate: json["dDate"] ?? "",
      dRequestDateTime: json["dRequestDateTime"] ?? "",
      cRequestDateTime: json["cRequestDateTime"] ?? "",
      cAccountName: json["cAccountName"] ?? "",
      cCategoryName: json["cCategoryName"] ?? "",
      cSectionName: json["cSectionName"] ?? "",
      cStatus: json["cStatus"] ?? "",
      nReqAmount: (json["nReqAmount"] as num?)?.toDouble() ?? 0.0,
      nTDS: (json["nTDS"] as num?)?.toDouble() ?? 0.0,
      nTax: (json["nTax"] as num?)?.toDouble() ?? 0.0,
      nPayable: (json["nPayable"] as num?)?.toDouble() ?? 0.0,
      nUserId: json["nUserId"] ?? 0,
      cUserName: json["cUserName"] ?? "",
    );
  }
}
