// class NotificationGetModal {
//   int? responseCode;
//   int? responseStatus;
//   List<ResponseData>? responseData;
//   String? responseMsg;
//
//   NotificationGetModal({this.responseCode, this.responseStatus, this.responseData, this.responseMsg});
//
//   NotificationGetModal.fromJson(Map<String, dynamic> json) {
//     responseCode = json['response_code'];
//     responseStatus = json['response_status'];
//     if (json['response_data'] != null) {
//       responseData = <ResponseData>[];
//       json['response_data'].forEach((v) {
//         responseData!.add(new ResponseData.fromJson(v));
//       });
//     }
//     responseMsg = json['response_msg'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['response_code'] = this.responseCode;
//     data['response_status'] = this.responseStatus;
//     if (this.responseData != null) {
//       data['response_data'] = this.responseData!.map((v) => v.toJson()).toList();
//     }
//     data['response_msg'] = this.responseMsg;
//     return data;
//   }
// }
//
// class ResponseData {
//   String? id;
//   String? mobile;
//   String? title;
//   String? message;
//   String? insertdatetime;
//
//   ResponseData({this.id, this.mobile, this.title, this.message, this.insertdatetime});
//
//   ResponseData.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     mobile = json['mobile'];
//     title = json['title'];
//     message = json['message'];
//     insertdatetime = json['insertdatetime'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['mobile'] = this.mobile;
//     data['title'] = this.title;
//     data['message'] = this.message;
//     data['insertdatetime'] = this.insertdatetime;
//     return data;
//   }
// }


class NotificationGetModal {
  int? responseCode;
  int? responseStatus;
  List<NotificationListItem>? responseData;
  String? responseMsg;

  NotificationGetModal({
    this.responseCode,
    this.responseStatus,
    this.responseData,
    this.responseMsg,
  });

  factory NotificationGetModal.fromJson(Map<String, dynamic> json) => NotificationGetModal(
    responseCode: json["response_code"],
    responseStatus: json["response_status"],
    responseData: json["response_data"] == null ? [] : List<NotificationListItem>.from(json["response_data"]!.map((x) => NotificationListItem.fromJson(x))),
    responseMsg: json["response_msg"],
  );

  Map<String, dynamic> toJson() => {
    "response_code": responseCode,
    "response_status": responseStatus,
    "response_data": responseData == null ? [] : List<dynamic>.from(responseData!.map((x) => x.toJson())),
    "response_msg": responseMsg,
  };
}

class NotificationListItem {
  String? id;
  String? categoryName;
  String? mobile;
  String? title;
  String? message;
  String? userId;
  String? userAppid;
  String? multicastId;
  String? successNotification;
  String? faliure;
  String? canonicalId;
  String? insertdatetime;
  String? status;

  NotificationListItem({
    this.id,
    this.categoryName,
    this.mobile,
    this.title,
    this.message,
    this.userId,
    this.userAppid,
    this.multicastId,
    this.successNotification,
    this.faliure,
    this.canonicalId,
    this.insertdatetime,
    this.status,
  });

  factory NotificationListItem.fromJson(Map<String, dynamic> json) => NotificationListItem(
    id: json["id"],
    categoryName: json["categoryName"],
    mobile: json["mobile"],
    title: json["title"],
    message: json["message"],
    userId: json["user_id"],
    userAppid: json["user_appid"],
    multicastId: json["multicast_id"],
    successNotification: json["success_notification"],
    faliure: json["faliure"],
    canonicalId: json["canonical_id"],
    insertdatetime: json["insertdatetime"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "categoryName": categoryName,
    "mobile": mobile,
    "title": title,
    "message": message,
    "user_id": userId,
    "user_appid": userAppid,
    "multicast_id": multicastId,
    "success_notification": successNotification,
    "faliure": faliure,
    "canonical_id": canonicalId,
    "insertdatetime": insertdatetime,
    "status": status,
  };
}
