class BedtimeLoginResponse {
  final int nFlag;
  final String cMessage;
  final BedtimeUser user;
  final List<MenuRights> menuRights;

  BedtimeLoginResponse({
    required this.nFlag,
    required this.cMessage,
    required this.user,
    required this.menuRights,
  });

  factory BedtimeLoginResponse.fromJson(Map<String, dynamic> json) {
    return BedtimeLoginResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      user: BedtimeUser.fromJson(json["user"] ?? {}),
      menuRights: (json["menuRights"] as List? ?? [])
          .map((e) => MenuRights.fromJson(e))
          .toList(),
    );
  }
}

class BedtimeUser {
  final int nUserId;
  final String cCusername;
  final String cEmail;
  final bool bActive;
  final int nCompanyID;

  BedtimeUser({
    required this.nUserId,
    required this.cCusername,
    required this.cEmail,
    required this.bActive,
    required this.nCompanyID,
  });

  factory BedtimeUser.fromJson(Map<String, dynamic> json) {
    return BedtimeUser(
      nUserId: json["nUserId"] ?? 0,
      cCusername: json["cCusername"] ?? "",
      cEmail: json["cEmail"] ?? "",
      bActive: json["bActive"] ?? false,
      nCompanyID: json["nCompanyID"] ?? 0,
    );
  }
}

class MenuRights {
  final int nUserId;
  final String cModule;
  final String cMenus;
  final int nCompanyID;

  MenuRights({
    required this.nUserId,
    required this.cModule,
    required this.cMenus,
    required this.nCompanyID,
  });

  factory MenuRights.fromJson(Map<String, dynamic> json) {
    return MenuRights(
      nUserId: json["nUserId"] ?? 0,
      cModule: json["cModule"] ?? "",
      cMenus: json["cMenus"] ?? "",
      nCompanyID: json["nCompanyID"] ?? 0,
    );
  }
}
