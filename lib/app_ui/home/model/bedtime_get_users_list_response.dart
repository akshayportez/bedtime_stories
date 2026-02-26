class BedtimeGetUsersListResponse {
  final int nFlag;
  final String cMessage;
  final List<BedtimeGetUsersList> data;

  BedtimeGetUsersListResponse({
    required this.nFlag,
    required this.cMessage,
    required this.data,
  });

  factory BedtimeGetUsersListResponse.fromJson(Map<String, dynamic> json) {
    return BedtimeGetUsersListResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      data: (json["data"] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => BedtimeGetUsersList.fromJson(item))
          .toList(),
    );
  }
}

class BedtimeGetUsersList {
  final int nUserId;
  final String cCusername;
  final String cEmail;
  final String cMobile;
  final bool bActive;
  final String dCreatedDate;
  final String? dModifiedDate;

  BedtimeGetUsersList({
    required this.nUserId,
    required this.cCusername,
    required this.cEmail,
    required this.cMobile,
    required this.bActive,
    required this.dCreatedDate,
    required this.dModifiedDate,
  });

  factory BedtimeGetUsersList.fromJson(Map<String, dynamic> json) {
    return BedtimeGetUsersList(
      nUserId: json["nUserId"] ?? 0,
      cCusername: json["cCusername"] ?? "",
      cEmail: json["cEmail"] ?? "",
      cMobile: json["cMobile"] ?? "",
      bActive: json["bActive"] ?? false,
      dCreatedDate: json["dCreatedDate"] ?? "",
      dModifiedDate: json["dModifiedDate"],
    );
  }
}
