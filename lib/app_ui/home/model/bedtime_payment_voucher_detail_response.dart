class BedtimePaymentVoucherDetailResponse {
  final int nFlag;
  final String cMessage;
  final BedtimePaymentVoucherReqHdr reqHdr;
  final List<BedtimePaymentVoucherTax> taxDtl;
  final List<String> files;
  final BedtimePaymentVoucherHdr voucherHdr;
  final BedtimePaymentVoucherPayDtl payDtl;

  BedtimePaymentVoucherDetailResponse({
    required this.nFlag,
    required this.cMessage,
    required this.reqHdr,
    required this.taxDtl,
    required this.files,
    required this.voucherHdr,
    required this.payDtl,
  });

  factory BedtimePaymentVoucherDetailResponse.fromJson(Map<String, dynamic> json) {
    return BedtimePaymentVoucherDetailResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      reqHdr: BedtimePaymentVoucherReqHdr.fromJson(
        (json["reqHdr"] as Map<String, dynamic>?) ?? const {},
      ),
      taxDtl: (json["taxDtl"] as List? ?? [])
          .map((e) => BedtimePaymentVoucherTax.fromJson((e as Map<String, dynamic>?) ?? const {}))
          .toList(),
      files: (json["files"] as List? ?? []).map(_fileItemToString).where((e) => e.isNotEmpty).toList(),
      voucherHdr: BedtimePaymentVoucherHdr.fromJson(
        (json["voucherHdr"] as Map<String, dynamic>?) ?? const {},
      ),
      payDtl: BedtimePaymentVoucherPayDtl.fromJson(
        (json["payDtl"] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }

  static String _fileItemToString(dynamic raw) {
    if (raw is String) return raw.trim();
    if (raw is Map<String, dynamic>) {
      final options = [
        raw["cFileName"],
        raw["cAttachment"],
        raw["fileName"],
        raw["path"],
      ];
      for (final value in options) {
        final text = value?.toString().trim() ?? "";
        if (text.isNotEmpty) return text;
      }
    }
    return "";
  }
}

class BedtimePaymentVoucherReqHdr {
  final int nPayReqId;
  final String cRequestNo;
  final String dRequestDateTime;
  final int nAccountId;
  final String cAccountName;
  final int nCategoryId;
  final String cCategoryName;
  final int nSectionId;
  final String cSectionName;
  final double nRequestedAmount;
  final bool bTDS;
  final double nTDSPercent;
  final double nTDSAmt;
  final bool bTaxable;
  final double nTaxAmount;
  final double nPayableAmount;
  final String cComment;
  final String cAttachment;
  final String cStatus;
  final int nApprovedBy;
  final String dApprovedDate;
  final int nProjectId;
  final String cRequestedBy;

  BedtimePaymentVoucherReqHdr({
    required this.nPayReqId,
    required this.cRequestNo,
    required this.dRequestDateTime,
    required this.nAccountId,
    required this.cAccountName,
    required this.nCategoryId,
    required this.cCategoryName,
    required this.nSectionId,
    required this.cSectionName,
    required this.nRequestedAmount,
    required this.bTDS,
    required this.nTDSPercent,
    required this.nTDSAmt,
    required this.bTaxable,
    required this.nTaxAmount,
    required this.nPayableAmount,
    required this.cComment,
    required this.cAttachment,
    required this.cStatus,
    required this.nApprovedBy,
    required this.dApprovedDate,
    required this.nProjectId,
    required this.cRequestedBy,
  });

  factory BedtimePaymentVoucherReqHdr.fromJson(Map<String, dynamic> json) {
    return BedtimePaymentVoucherReqHdr(
      nPayReqId: json["nPayReqId"] ?? 0,
      cRequestNo: json["cRequestNo"] ?? "",
      dRequestDateTime: json["dRequestDateTime"] ?? "",
      nAccountId: json["nAccountId"] ?? 0,
      cAccountName: json["cAccountName"] ?? "",
      nCategoryId: json["nCategoryId"] ?? 0,
      cCategoryName: json["cCategoryName"] ?? "",
      nSectionId: json["nSectionId"] ?? 0,
      cSectionName: json["cSectionName"] ?? "",
      nRequestedAmount: (json["nRequestedAmount"] as num?)?.toDouble() ?? 0.0,
      bTDS: json["bTDS"] ?? false,
      nTDSPercent: (json["nTDSPercent"] as num?)?.toDouble() ?? 0.0,
      nTDSAmt: (json["nTDSAmt"] as num?)?.toDouble() ?? 0.0,
      bTaxable: json["bTaxable"] ?? false,
      nTaxAmount: (json["nTaxAmount"] as num?)?.toDouble() ?? 0.0,
      nPayableAmount: (json["nPayableAmount"] as num?)?.toDouble() ?? 0.0,
      cComment: json["cComment"] ?? "",
      cAttachment: json["cAttachment"] ?? "",
      cStatus: json["cStatus"] ?? "",
      nApprovedBy: json["nApprovedBy"] ?? 0,
      dApprovedDate: json["dApprovedDate"] ?? "",
      nProjectId: json["nProjectId"] ?? 0,
      cRequestedBy: json["cRequestedBy"] ?? "",
    );
  }
}

class BedtimePaymentVoucherTax {
  final int nTaxId;
  final String cTaxName;
  final double nTaxRate;

  BedtimePaymentVoucherTax({
    required this.nTaxId,
    required this.cTaxName,
    required this.nTaxRate,
  });

  factory BedtimePaymentVoucherTax.fromJson(Map<String, dynamic> json) {
    return BedtimePaymentVoucherTax(
      nTaxId: json["nTaxId"] ?? 0,
      cTaxName: json["cTaxName"] ?? "",
      nTaxRate: (json["nTaxRate"] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BedtimePaymentVoucherHdr {
  final int nPayVoucherId;
  final int nPayReqId;
  final String cPayMode;
  final String dVoucherDate;
  final bool bActive;

  BedtimePaymentVoucherHdr({
    required this.nPayVoucherId,
    required this.nPayReqId,
    required this.cPayMode,
    required this.dVoucherDate,
    required this.bActive,
  });

  factory BedtimePaymentVoucherHdr.fromJson(Map<String, dynamic> json) {
    return BedtimePaymentVoucherHdr(
      nPayVoucherId: json["nPayVoucherId"] ?? 0,
      nPayReqId: json["nPayReqId"] ?? 0,
      cPayMode: json["cPayMode"] ?? "",
      dVoucherDate: json["dVoucherDate"] ?? "",
      bActive: json["bActive"] ?? false,
    );
  }
}

class BedtimePaymentVoucherPayDtl {
  final int nPayDtlId;
  final String cChequeNo;
  final String dChequeDate;
  final int nBankId;
  final String cBankName;
  final String cUPIRefNo;
  final String cUpiApp;
  final double nRequestedAmount;
  final double nTDSAmount;
  final double nTaxAmount;
  final double nPayableAmount;
  final String cComment;

  BedtimePaymentVoucherPayDtl({
    required this.nPayDtlId,
    required this.cChequeNo,
    required this.dChequeDate,
    required this.nBankId,
    required this.cBankName,
    required this.cUPIRefNo,
    required this.cUpiApp,
    required this.nRequestedAmount,
    required this.nTDSAmount,
    required this.nTaxAmount,
    required this.nPayableAmount,
    required this.cComment,
  });

  factory BedtimePaymentVoucherPayDtl.fromJson(Map<String, dynamic> json) {
    return BedtimePaymentVoucherPayDtl(
      nPayDtlId: json["nPayDtlId"] ?? 0,
      cChequeNo: json["cChequeNo"] ?? "",
      dChequeDate: json["dChequeDate"] ?? "",
      nBankId: json["nBankId"] ?? 0,
      cBankName: json["cBankName"] ?? "",
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
