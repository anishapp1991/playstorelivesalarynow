class LoginVerifyCallModal {
  int? responseCode;
  int? responseStatus;
  ResponseData? responseData;
  String? responseMsg;

  LoginVerifyCallModal({
    this.responseCode,
    this.responseStatus,
    this.responseData,
    this.responseMsg,
  });

  factory LoginVerifyCallModal.fromJson(Map<String, dynamic> json) => LoginVerifyCallModal(
    responseCode: json["response_code"],
    responseStatus: json["response_status"],
    responseData: json["response_data"] == null ? null : ResponseData.fromJson(json["response_data"]),
    responseMsg: json["response_msg"],
  );

  Map<String, dynamic> toJson() => {
    "response_code": responseCode,
    "response_status": responseStatus,
    "response_data": responseData?.toJson(),
    "response_msg": responseMsg,
  };
}

class ResponseData {
  String? mobile;
  String? callersid;

  ResponseData({
    this.mobile,
    this.callersid,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) => ResponseData(
    mobile: json["mobile"],
    callersid: json["callersid"],
  );

  Map<String, dynamic> toJson() => {
    "mobile": mobile,
    "callersid": callersid,
  };
}
