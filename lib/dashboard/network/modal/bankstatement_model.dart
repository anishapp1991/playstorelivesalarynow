class BankStatmentModal {
  int? responseCode;
  int? responseStatus;
  ResponseData? data;
  String? responseMsg;

  BankStatmentModal({
    this.responseCode,
    this.responseStatus,
    this.data,
    this.responseMsg,
  });

  factory BankStatmentModal.fromJson(Map<String, dynamic> json) => BankStatmentModal(
        responseCode: json["response_code"],
        responseStatus: json["response_status"],
        data: json["data"] == null ? null : ResponseData.fromJson(json["data"]),
        responseMsg: json["response_msg"],
      );

  Map<String, dynamic> toJson() => {
        "response_code": responseCode,
        "response_status": responseStatus,
        "data": data?.toJson(),
        "response_msg": responseMsg,
      };
}

class ResponseData {
  String? showmessage;
  String? from;
  String? to;
  bool uploadstatus;

  ResponseData({
    this.showmessage,
    this.from,
    this.to,
    required this.uploadstatus,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) => ResponseData(
        showmessage: json["showmessage"],
        from: json["from"],
        to: json["to"],
        uploadstatus: json["uploadstatus"],
      );

  Map<String, dynamic> toJson() => {
        "showmessage": showmessage,
        "from": from,
        "to": to,
        "uploadstatus": uploadstatus,
      };
}
