class BedtimePaymentRequestResponse {
  final int nFlag;
  final String cMessage;
  final List<BedtimePaymentRequest> data;

  BedtimePaymentRequestResponse({
    required this.nFlag,
    required this.cMessage,
    required this.data,
  });

  factory BedtimePaymentRequestResponse.fromJson(Map<String, dynamic> json) {
    return BedtimePaymentRequestResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      data: (json["data"] as List? ?? [])
          .map((e) => BedtimePaymentRequest.fromJson(e))
          .toList(),
    );
  }
}

class BedtimePaymentRequest {
  final int nPayReqId;
  final String cRequestNo;
  final String? cVoucherNo;
  final String? dRequestDateTime;
  final String? cRequestDateTime;
  final int nRequestedBy;
  final String cRequestedBy;
  final String? dRejectedDateTime;
  final String? cRejectedDateTime;
  final String? cRejectedBy;
  final String? dApprovedDateTime;
  final String? cApprovedDateTime;
  final String? cApprovedBy;
  final String? dVoucherDateTime;
  final String? cVoucherDateTime;
  final String? cPaidBy;
  final int nAccountId;
  final String cAccountName;
  final int nCategoryId;
  final String cCategoryName;
  final int nSectionId;
  final String cSectionName;
  final double nPayableAmount;
  final String cStatus;

  BedtimePaymentRequest({
    required this.nPayReqId,
    required this.cRequestNo,
    required this.cVoucherNo,
    required this.dRequestDateTime,
    required this.cRequestDateTime,
    required this.nRequestedBy,
    required this.cRequestedBy,
    required this.dRejectedDateTime,
    required this.cRejectedDateTime,
    required this.cRejectedBy,
    required this.dApprovedDateTime,
    required this.cApprovedDateTime,
    required this.cApprovedBy,
    required this.dVoucherDateTime,
    required this.cVoucherDateTime,
    required this.cPaidBy,
    required this.nAccountId,
    required this.cAccountName,
    required this.nCategoryId,
    required this.cCategoryName,
    required this.nSectionId,
    required this.cSectionName,
    required this.nPayableAmount,
    required this.cStatus,
  });

  factory BedtimePaymentRequest.fromJson(Map<String, dynamic> json) {
    return BedtimePaymentRequest(
      nPayReqId: json["nPayReqId"] ?? 0,
      cRequestNo: json["cRequestNo"] ?? "",
      cVoucherNo: json["cVoucherNo"],
      dRequestDateTime: json["dRequestDateTime"],
      cRequestDateTime: json["cRequestDateTime"],
      nRequestedBy: json["nRequestedBy"] ?? 0,
      cRequestedBy: json["cRequestedBy"] ?? "",
      dRejectedDateTime: json["dRejectedDateTime"],
      cRejectedDateTime: json["cRejectedDateTime"],
      cRejectedBy: json["cRejectedBy"],
      dApprovedDateTime: json["dApprovedDateTime"],
      cApprovedDateTime: json["cApprovedDateTime"],
      cApprovedBy: json["cApprovedBy"],
      dVoucherDateTime: json["dVoucherDateTime"],
      cVoucherDateTime: json["cVoucherDateTime"],
      cPaidBy: json["cPaidBy"],
      nAccountId: json["nAccountId"] ?? 0,
      cAccountName: json["cAccountName"] ?? "",
      nCategoryId: json["nCategoryId"] ?? 0,
      cCategoryName: json["cCategoryName"] ?? "",
      nSectionId: json["nSectionId"] ?? 0,
      cSectionName: json["cSectionName"] ?? "",
      nPayableAmount: (json["nPayableAmount"] as num?)?.toDouble() ?? 0.0,
      cStatus: json["cStatus"] ?? "",
    );
  }
}
