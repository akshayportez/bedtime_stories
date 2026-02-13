class BedtimeVoucherReportResponse {
  final int nFlag;
  final String cMessage;
  final List<BedtimeVoucherReportRow> data;

  BedtimeVoucherReportResponse({
    required this.nFlag,
    required this.cMessage,
    required this.data,
  });

  factory BedtimeVoucherReportResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json["data"] as List? ?? const [];
    return BedtimeVoucherReportResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      data: rawData
          .map((e) => BedtimeVoucherReportRow.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(),
    );
  }
}

class BedtimeVoucherReportRow {
  final String cVoucherNo;
  final String cVoucherDate;
  final String cUserName;
  final String cAccountName;
  final String cCategoryName;
  final String cSectionName;
  final double nPayableAmount;
  final String cPayMode;

  BedtimeVoucherReportRow({
    required this.cVoucherNo,
    required this.cVoucherDate,
    required this.cUserName,
    required this.cAccountName,
    required this.cCategoryName,
    required this.cSectionName,
    required this.nPayableAmount,
    required this.cPayMode,
  });

  factory BedtimeVoucherReportRow.fromJson(Map<String, dynamic> json) {
    return BedtimeVoucherReportRow(
      cVoucherNo: _readString(
        json,
        const ["cVoucherNo", "cVouNo", "cVoucherNumber", "cRequestNo"],
      ),
      cVoucherDate: _readString(
        json,
        const [
          "cVoucherDate",
          "cVoucherDateTime",
          "dVoucherDateTime",
          "cDate",
          "dDate",
        ],
      ),
      cUserName: _readString(
        json,
        const ["cUserName", "cRequestedBy", "cCreatedBy", "cUser"],
      ),
      cAccountName: _readString(json, const ["cAccountName"]),
      cCategoryName: _readString(json, const ["cCategoryName"]),
      cSectionName: _readString(json, const ["cSectionName"]),
      nPayableAmount: _readDouble(
        json,
        const ["nPayableAmount", "nAmount", "nRequestedAmount"],
      ),
      cPayMode: _readString(
        json,
        const ["cPayMode", "cPayModes", "cMode", "cPaymentMode"],
      ),
    );
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final resolved = value.toString().trim();
      if (resolved.isNotEmpty) return resolved;
    }
    return "";
  }

  static double _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value.replaceAll(",", "").trim());
        if (parsed != null) return parsed;
      }
    }
    return 0.0;
  }
}
