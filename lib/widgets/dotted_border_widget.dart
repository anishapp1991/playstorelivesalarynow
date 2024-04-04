import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';

import '../utils/color.dart';

class MyDottedBorder extends StatelessWidget {
  final Color? color;
  final Widget widget;
  final Radius? radius;
  final BorderType? borderType;
  const MyDottedBorder({
    super.key,
    required this.widget,
    this.color,
    this.radius,
    this.borderType,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: borderType ?? BorderType.Rect,
      color: color ?? MyColor.turcoiseColor,
      strokeWidth: 1,
      radius: radius ?? const Radius.circular(0),
      dashPattern: const <double>[5, 5],
      strokeCap: StrokeCap.butt,
      child: widget,
    );
  }
}
