import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:salarynow/Notification/cubit/get_notifiction/get_notification_cubit.dart';
import 'package:salarynow/utils/color.dart';
import 'package:salarynow/widgets/empty_container.dart';
import 'package:salarynow/widgets/error.dart';
import 'package:salarynow/widgets/information_widgets/info_appbar_widget.dart';
import 'package:salarynow/widgets/loader.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../widgets/text_widget.dart';
import '../network/modal/get_notification_modal.dart';

class NotificationDetails extends StatefulWidget {
  final NotificationListItem notificationItemModal;
  NotificationDetails({Key? key, required this.notificationItemModal}) : super(key: key);

  @override
  State<NotificationDetails> createState() => _NotificationDetailsState();
}

class _NotificationDetailsState extends State<NotificationDetails> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar:  InfoCustomAppBar(title: widget.notificationItemModal.title),
        body: Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Chip(
                  backgroundColor: MyColor.light1BlueColor,
                  label: Text(getTime(
                    widget.notificationItemModal.insertdatetime ?? '',
                  ),style: TextStyle(fontSize: 12,color: MyColor.primaryBlueColor),),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.0), // Adjust the radius as needed
                  ),
                  elevation: 2,
                  child: Container(
                    constraints: BoxConstraints(
                      // minHeight: 200.0, // Set your desired minimum height here
                    ),
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(10),
                    child: MyText(
                      text: widget.notificationItemModal.message ?? "",
                      fontSize: 16.sp,
                      letterSpacing: 2.0,
                      wordSpacing: 5.0,
                      fontWeight: FontWeight.w500,
                      // color: MyColor.subtitleTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getTime(String date) {
    String dateString = date.substring(0, 19) + date.substring(19, 22).toUpperCase();
    DateTime dateTime = DateFormat('yyyy-MM-dd hh:mm:ss a').parse(dateString);
    String formattedDateTime = DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
    DateTime dateTime2 = DateFormat('yyyy-MM-dd hh:mm:ss a').parse(formattedDateTime);
    String timeAgo = timeago.format(dateTime2);
    return timeAgo;
  }
}
