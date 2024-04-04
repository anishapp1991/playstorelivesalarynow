

import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salarynow/utils/color.dart';
import 'package:salarynow/utils/written_text.dart';

class MyTextStyle {
  static TextStyle? myText = TextStyle(
    fontSize: 16.sp,
    color: MyColor.blackColor,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    fontFamily: MyWrittenText.roboto,
  );
}
