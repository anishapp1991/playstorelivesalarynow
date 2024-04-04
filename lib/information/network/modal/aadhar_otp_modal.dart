class AadhaarOtpModal {
  int? responseCode;
  int? responseStatus;
  ResponseData? responseData;
  String? responseMsg;
  bool? response_skip;

  AadhaarOtpModal({this.responseCode, this.responseStatus, this.responseData, this.responseMsg, this.response_skip});

  AadhaarOtpModal.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    responseStatus = json['response_status'];
    if (json['response_data'] != null) {
      if (json['response_data'] is Map<String, dynamic>) {
        responseData = ResponseData.fromJson(json['response_data']);
      } else if (json['response_data'] is List<dynamic>) {
        responseData = ResponseData(data: null);
      }
    }
    responseMsg = json['response_msg'];
    response_skip = json['response_skip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['response_code'] = this.responseCode;
    data['response_status'] = this.responseStatus;
    if (this.responseData != null) {
      data['response_data'] = this.responseData!.toJson();
    }
    data['response_msg'] = this.responseMsg;
    data['response_skip'] = this.response_skip;
    return data;
  }
}

class ResponseData {
  Data? data;
  int? statusCode;
  String? messageCode;
  String? message;
  bool? success;

  ResponseData({this.data, this.statusCode, this.messageCode, this.message, this.success});

  ResponseData.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    statusCode = json['status_code'];
    messageCode = json['message_code'];
    message = json['message'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status_code'] = this.statusCode;
    data['message_code'] = this.messageCode;
    data['message'] = this.message;
    data['success'] = this.success;
    return data;
  }
}

class Data {
  String? clientId;
  bool? otpSent;
  bool? ifNumber;
  bool? validAadhaar;
  String? status;

  Data({this.clientId, this.otpSent, this.ifNumber, this.validAadhaar, this.status});

  Data.fromJson(Map<String, dynamic> json) {
    clientId = json['client_id'];
    otpSent = json['otp_sent'];
    ifNumber = json['if_number'];
    validAadhaar = json['valid_aadhaar'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['client_id'] = this.clientId;
    data['otp_sent'] = this.otpSent;
    data['if_number'] = this.ifNumber;
    data['valid_aadhaar'] = this.validAadhaar;
    data['status'] = this.status;
    return data;
  }
}
