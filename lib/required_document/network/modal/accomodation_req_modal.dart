class AccomodationReqModal {
  int? responseCode;
  int? responseStatus;
  Data? data;
  String? responseMsg;

  AccomodationReqModal({this.responseCode, this.responseStatus, this.data, this.responseMsg});

  AccomodationReqModal.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    responseStatus = json['response_status'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    responseMsg = json['response_msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['response_code'] = this.responseCode;
    data['response_status'] = this.responseStatus;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['response_msg'] = this.responseMsg;
    return data;
  }
}

class Data {
  String? front;
  String? documentType;
  String? residencialStatus;

  Data({this.front, this.documentType, this.residencialStatus});

  Data.fromJson(Map<String, dynamic> json) {
    front = json['front'];
    documentType = json['document_type'];
    residencialStatus = json['residencial_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['front'] = this.front;
    data['document_type'] = this.documentType;
    data['residencial_status'] = this.residencialStatus;
    return data;
  }
}
