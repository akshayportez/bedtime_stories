class BedtimePaymentVoucherResponse {
  final int nFlag;
  final String cMessage;
  final List<BedtimePaymentVoucher> data;

  BedtimePaymentVoucherResponse({
    required this.nFlag,
    required this.cMessage,
    required this.data,
  });

  factory BedtimePaymentVoucherResponse.fromJson(Map<String, dynamic> json) {
    return BedtimePaymentVoucherResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      data: (json["data"] as List? ?? [])
          .map((e) => BedtimePaymentVoucher.fromJson(e))
          .toList(),
    );
  }
}

class BedtimePaymentVoucher {
  final int nPayReqId;
  final int nPayVoucherId;
  final String cApprovedBy;
  final String? dApprovedDate;
  final String cApprovedDate;
  final String cRequestNo;
  final String cVoucherNo;
  final int nRequestedBy;
  final String cRequestedBy;
  final String? dRequestDateTime;
  final String? cRequestDateTime;
  final String? dVoucherDate;
  final String cVoucherDate;
  final String cPaidBy;
  final String? dRejectedDateTime;
  final String? cRejectedDateTime;
  final String cRejectedBy;
  final String cAccountName;
  final String cCategoryName;
  final String cSectionName;
  final double nPayableAmount;
  final String cPaymode;
  final String cStatus;

  BedtimePaymentVoucher({
    required this.nPayReqId,
    required this.nPayVoucherId,
    required this.cApprovedBy,
    required this.dApprovedDate,
    required this.cApprovedDate,
    required this.cRequestNo,
    required this.cVoucherNo,
    required this.nRequestedBy,
    required this.cRequestedBy,
    required this.dRequestDateTime,
    required this.cRequestDateTime,
    required this.dVoucherDate,
    required this.cVoucherDate,
    required this.cPaidBy,
    required this.dRejectedDateTime,
    required this.cRejectedDateTime,
    required this.cRejectedBy,
    required this.cAccountName,
    required this.cCategoryName,
    required this.cSectionName,
    required this.nPayableAmount,
    required this.cPaymode,
    required this.cStatus,
  });

  factory BedtimePaymentVoucher.fromJson(Map<String, dynamic> json) {
    return BedtimePaymentVoucher(
      nPayReqId: json["nPayReqId"] ?? 0,
      nPayVoucherId: json["nPayVoucherId"] ?? 0,
      cApprovedBy: json["cApprovedBy"] ?? "",
      dApprovedDate: json["dApprovedDate"],
      cApprovedDate: json["cApprovedDate"] ?? "",
      cRequestNo: json["cRequestNo"] ?? "",
      cVoucherNo: json["cVoucherNo"] ?? "",
      nRequestedBy: json["nRequestedBy"] ?? 0,
      cRequestedBy: json["cRequestedBy"] ?? "",
      dRequestDateTime: json["dRequestDateTime"],
      cRequestDateTime: json["cRequestDateTime"],
      dVoucherDate: json["dVoucherDate"],
      cVoucherDate: json["cVoucherDate"] ?? "",
      cPaidBy: json["cPaidBy"] ?? "",
      dRejectedDateTime: json["dRejectedDateTime"],
      cRejectedDateTime: json["cRejectedDateTime"],
      cRejectedBy: json["cRejectedBy"] ?? "",
      cAccountName: json["cAccountName"] ?? "",
      cCategoryName: json["cCategoryName"] ?? "",
      cSectionName: json["cSectionName"] ?? "",
      nPayableAmount: (json["nPayableAmount"] as num?)?.toDouble() ?? 0.0,
      cPaymode: json["cPaymode"] ?? "",
      cStatus: json["cStatus"] ?? "",
    );
  }
}
