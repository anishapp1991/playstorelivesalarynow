class LoginVrCallBackModal {
  int? responseCode;
  int? responseStatus;
  String? responseData;
  String? responseMsg;

  LoginVrCallBackModal({
    this.responseCode,
    this.responseStatus,
    this.responseData,
    this.responseMsg,
  });

  factory LoginVrCallBackModal.fromJson(Map<String, dynamic> json) => LoginVrCallBackModal(
    responseCode: json["response_code"],
    responseStatus: json["response_status"],
    responseData: json["response_data"],
    responseMsg: json["response_msg"],
  );

  Map<String, dynamic> toJson() => {
    "response_code": responseCode,
    "response_status": responseStatus,
    "response_data": responseData,
    "response_msg": responseMsg,
  };
}
