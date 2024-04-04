class LoanAgreementDataModel {
  int? responseCode;
  int? responseStatus;
  List<ResponseData>? responseData;
  String? responseMsg;

  LoanAgreementDataModel({this.responseCode, this.responseStatus, this.responseData, this.responseMsg});

  LoanAgreementDataModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    responseStatus = json['response_status'];
    if (json['response_data'] != null) {
      responseData = <ResponseData>[];
      json['response_data'].forEach((v) {
        responseData!.add(new ResponseData.fromJson(v));
      });
    }
    responseMsg = json['response_msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['response_code'] = this.responseCode;
    data['response_status'] = this.responseStatus;
    if (this.responseData != null) {
      data['response_data'] = this.responseData!.map((v) => v.toJson()).toList();
    }
    data['response_msg'] = this.responseMsg;
    return data;
  }
}

class ResponseData {
  String? key;
  String? val;

  ResponseData({this.key, this.val});

  ResponseData.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    val = json['val'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['val'] = this.val;
    return data;
  }
}
