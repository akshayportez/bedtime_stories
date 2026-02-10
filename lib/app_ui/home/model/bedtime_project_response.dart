class BedtimeProjectResponse {
  final int nFlag;
  final String cMessage;
  final List<BedtimeProject> data;

  BedtimeProjectResponse({
    required this.nFlag,
    required this.cMessage,
    required this.data,
  });

  factory BedtimeProjectResponse.fromJson(Map<String, dynamic> json) {
    return BedtimeProjectResponse(
      nFlag: json["nFlag"] ?? 0,
      cMessage: json["cMessage"] ?? "",
      data: (json["data"] as List? ?? [])
          .map((e) => BedtimeProject.fromJson(e))
          .toList(),
    );
  }
}

class BedtimeProject {
  final int nProjectId;
  final String cProjectName;
  final String cProjectShName;
  final bool bActive;
  final String dCreatedDate;
  final String? dModifiedDate;
  final int nUserCount;

  BedtimeProject({
    required this.nProjectId,
    required this.cProjectName,
    required this.cProjectShName,
    required this.bActive,
    required this.dCreatedDate,
    required this.dModifiedDate,
    required this.nUserCount,
  });

  factory BedtimeProject.fromJson(Map<String, dynamic> json) {
    return BedtimeProject(
      nProjectId: json["nProjectId"] ?? 0,
      cProjectName: json["cProjectName"] ?? "",
      cProjectShName: json["cProjectShName"] ?? "",
      bActive: json["bActive"] ?? false,
      dCreatedDate: json["dCreatedDate"] ?? "",
      dModifiedDate: json["dModifiedDate"],
      nUserCount: json["nUserCount"] ?? 0,
    );
  }
}
