class BedtimePaymentRequestDetailResponse {
  final int nFlag;
  final String cMessage;
  final BedtimePaymentRequestDetail data;
  final List<BedtimePaymentRequestTax> taxDtl;

  BedtimePaymentRequestDetailResponse({
    required this.nFlag,
    required this.cMessage,
    required this.data,
    required this.taxDtl,
  });

  factory BedtimePaymentRequestDetailResponse.fromJson(
      Map<String, dynamic> json) {
    return BedtimePaymentRequestDetailResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      data: BedtimePaymentRequestDetail.fromJson(json["data"] ?? {}),
      taxDtl: (json["taxDtl"] as List? ?? [])
          .map((e) => BedtimePaymentRequestTax.fromJson(e))
          .toList(),
    );
  }
}

class BedtimePaymentRequestDetail {
  final int nPayReqId;
  final String cRequestNo;
  final String? dRequestDateTime;
  final String? cRequestDateTime;
  final String? dRejectedDateTime;
  final String? cRejectedDateTime;
  final String? dApprovedDateTime;
  final String? cApprovedDateTime;
  final String? dVoucherDateTime;
  final String? cVoucherDateTime;
  final int nAccountId;
  final int nCategoryId;
  final int nSectionId;
  final double nRequestedAmount;
  final double nTDSAmount;
  final bool bTDS;
  final double nTDSPercent;
  final bool bTaxable;
  final double nTaxAmount;
  final double nPayableAmount;
  final String cComment;
  final String cAttachment;
  final String cStatus;
  final int nProjectId;
  final bool bActive;
  final BedtimePaymentRequestPayDetail payDtl;

  BedtimePaymentRequestDetail({
    required this.nPayReqId,
    required this.cRequestNo,
    required this.dRequestDateTime,
    required this.cRequestDateTime,
    required this.dRejectedDateTime,
    required this.cRejectedDateTime,
    required this.dApprovedDateTime,
    required this.cApprovedDateTime,
    required this.dVoucherDateTime,
    required this.cVoucherDateTime,
    required this.nAccountId,
    required this.nCategoryId,
    required this.nSectionId,
    required this.nRequestedAmount,
    required this.nTDSAmount,
    required this.bTDS,
    required this.nTDSPercent,
    required this.bTaxable,
    required this.nTaxAmount,
    required this.nPayableAmount,
    required this.cComment,
    required this.cAttachment,
    required this.cStatus,
    required this.nProjectId,
    required this.bActive,
    required this.payDtl,
  });

  factory BedtimePaymentRequestDetail.fromJson(Map<String, dynamic> json) {
    return BedtimePaymentRequestDetail(
      nPayReqId: json["nPayReqId"] ?? 0,
      cRequestNo: json["cRequestNo"] ?? "",
      dRequestDateTime: json["dRequestDateTime"],
      cRequestDateTime: json["cRequestDateTime"],
      dRejectedDateTime: json["dRejectedDateTime"],
      cRejectedDateTime: json["cRejectedDateTime"],
      dApprovedDateTime: json["dApprovedDateTime"],
      cApprovedDateTime: json["cApprovedDateTime"],
      dVoucherDateTime: json["dVoucherDateTime"],
      cVoucherDateTime: json["cVoucherDateTime"],
      nAccountId: json["nAccountId"] ?? 0,
      nCategoryId: json["nCategoryId"] ?? 0,
      nSectionId: json["nSectionId"] ?? 0,
      nRequestedAmount: (json["nRequestedAmount"] as num?)?.toDouble() ?? 0.0,
      nTDSAmount: (json["nTDSAmount"] as num?)?.toDouble() ?? 0.0,
      bTDS: json["bTDS"] ?? false,
      nTDSPercent: (json["nTDSPercent"] as num?)?.toDouble() ?? 0.0,
      bTaxable: json["bTaxable"] ?? false,
      nTaxAmount: (json["nTaxAmount"] as num?)?.toDouble() ?? 0.0,
      nPayableAmount: (json["nPayableAmount"] as num?)?.toDouble() ?? 0.0,
      cComment: json["cComment"] ?? "",
      cAttachment: json["cAttachment"] ?? "",
      cStatus: json["cStatus"] ?? "",
      nProjectId: json["nProjectId"] ?? 0,
      bActive: json["bActive"] ?? false,
      payDtl:
          BedtimePaymentRequestPayDetail.fromJson(json["payDtl"] ?? const {}),
    );
  }
}

class BedtimePaymentRequestPayDetail {
  final int nPayDtlId;
  final String cChequeNo;
  final String dChequeDate;
  final int nBankId;
  final String cUPIRefNo;
  final String cUpiApp;
  final double nRequestedAmount;
  final double nTDSAmount;
  final double nTaxAmount;
  final double nPayableAmount;
  final String cComment;

  BedtimePaymentRequestPayDetail({
    required this.nPayDtlId,
    required this.cChequeNo,
    required this.dChequeDate,
    required this.nBankId,
    required this.cUPIRefNo,
    required this.cUpiApp,
    required this.nRequestedAmount,
    required this.nTDSAmount,
    required this.nTaxAmount,
    required this.nPayableAmount,
    required this.cComment,
  });

  factory BedtimePaymentRequestPayDetail.fromJson(Map<String, dynamic> json) {
    return BedtimePaymentRequestPayDetail(
      nPayDtlId: json["nPayDtlId"] ?? 0,
      cChequeNo: json["cChequeNo"] ?? "",
      dChequeDate: json["dChequeDate"] ?? "",
      nBankId: json["nBankId"] ?? 0,
      cUPIRefNo: json["cUPIRefNo"] ?? "",
      cUpiApp: json["cUpiApp"] ?? "",
      nRequestedAmount: (json["nRequestedAmount"] as num?)?.toDouble() ?? 0.0,
      nTDSAmount: (json["nTDSAmount"] as num?)?.toDouble() ?? 0.0,
      nTaxAmount: (json["nTaxAmount"] as num?)?.toDouble() ?? 0.0,
      nPayableAmount: (json["nPayableAmount"] as num?)?.toDouble() ?? 0.0,
      cComment: json["cComment"] ?? "",
    );
  }
}

class BedtimePaymentRequestTax {
  final int nTaxId;
  final String cTaxName;
  final double nTaxRate;

  BedtimePaymentRequestTax({
    required this.nTaxId,
    required this.cTaxName,
    required this.nTaxRate,
  });

  factory BedtimePaymentRequestTax.fromJson(Map<String, dynamic> json) {
    return BedtimePaymentRequestTax(
      nTaxId: json["nTaxId"] ?? 0,
      cTaxName: json["cTaxName"] ?? "",
      nTaxRate: (json["nTaxRate"] as num?)?.toDouble() ?? 0.0,
    );
  }
}
