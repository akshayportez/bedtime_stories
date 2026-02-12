class BedtimePaymentVoucherSaveResponse {
  final int nFlag;
  final String cMessage;
  final int nPayVoucherId;

  BedtimePaymentVoucherSaveResponse({
    required this.nFlag,
    required this.cMessage,
    required this.nPayVoucherId,
  });

  factory BedtimePaymentVoucherSaveResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic data = json["data"];
    int resolvedPayVoucherId = 0;

    if (data is Map<String, dynamic>) {
      final value = data["nPayVoucherId"];
      if (value is int) {
        resolvedPayVoucherId = value;
      } else {
        resolvedPayVoucherId = int.tryParse(value?.toString() ?? "") ?? 0;
      }
    } else {
      final rootValue = json["nPayVoucherId"];
      if (rootValue is int) {
        resolvedPayVoucherId = rootValue;
      } else {
        resolvedPayVoucherId = int.tryParse(rootValue?.toString() ?? "") ?? 0;
      }
    }

    return BedtimePaymentVoucherSaveResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      nPayVoucherId: resolvedPayVoucherId,
    );
  }
}
