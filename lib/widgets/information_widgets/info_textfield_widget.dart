// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../utils/color.dart';
// import '../text_widget.dart';
//
// class InfoTextFieldWidget extends StatelessWidget {
//   final String title;
//   final bool? autoFocus;
//   final bool? enabled;
//   final TextEditingController textEditingController;
//   final bool isPass;
//   final String? hintText;
//   final String? initialValue;
//   final TextStyle? hintStyle;
//   final TextInputType? textInputType;
//   final Icon? icon;
//   final Widget? suffixIcon;
//   final int? maxLines;
//   final FormFieldValidator<String?>? validator;
//   final TextInputAction? textInputAction;
//   final int? maxLength;
//   final TextCapitalization? textCapitalization;
//   final List<TextInputFormatter>? inputFormatters;
//   final ValueChanged<String>? onChanged;
//   final Color? fillColor;
//   final EdgeInsets? scrollPadding;
//   final GlobalKey<FormFieldState>? formFieldKey;
//   final GestureTapCallback? onTap;
//   final FocusNode? focusNode;
//   final Color? errorColor;
//   final Color? errorBorder;
//   final String? errorText;
//   final ValueChanged<String>? onFieldSubmitted;
//
//   const InfoTextFieldWidget({
//     Key? key,
//     required this.title,
//     required this.textEditingController,
//     this.textInputType,
//     this.hintText,
//     this.icon,
//     this.suffixIcon,
//     this.isPass = false,
//     this.validator,
//     this.maxLines,
//     this.textInputAction,
//     this.maxLength,
//     this.autoFocus,
//     this.enabled,
//     this.initialValue,
//     this.hintStyle,
//     this.textCapitalization,
//     this.inputFormatters,
//     this.onChanged,
//     this.fillColor,
//     this.scrollPadding,
//     this.formFieldKey,
//     this.onTap,
//     this.focusNode,
//     this.errorColor,
//     this.errorBorder,
//     this.errorText,
//     this.onFieldSubmitted
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final border = OutlineInputBorder(
//       borderRadius: BorderRadius.circular(5.r),
//       borderSide: const BorderSide(width: 1, color: MyColor.textFieldBorderColor), //<-- SEE HERE
//     );
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         MyText(text: title, fontSize: 18.h),
//         SizedBox(height: 10.h),
//         TextFormField(
//           focusNode: focusNode,
//           style: TextStyle(fontSize: 16.sp, color: MyColor.placeHolderColor),
//           initialValue: initialValue,
//           enabled: enabled ?? true,
//           autofocus: autoFocus ?? false,
//           inputFormatters: inputFormatters,
//           cursorColor: MyColor.turcoiseColor,
//           textCapitalization: textCapitalization ?? TextCapitalization.none,
//           scrollPadding: scrollPadding ?? EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom + 16*4),
//           maxLength: maxLength,
//           maxLines: maxLines ?? 1,
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           validator: validator,
//           controller: textEditingController,
//           onChanged: onChanged,
//           textInputAction: textInputAction ?? TextInputAction.next,
//           keyboardType: textInputType ?? TextInputType.text,
//           obscureText: isPass,
//           key: formFieldKey,
//           onTap: onTap,
//           onFieldSubmitted:onFieldSubmitted,
//           decoration: InputDecoration(
//             fillColor: fillColor ?? MyColor.whiteColor,
//             errorStyle: TextStyle(color: (errorColor ?? MyColor.redColor)),
//             errorBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: errorBorder ?? MyColor.redColor),
//             ),
//             disabledBorder: border,
//             suffixIcon: suffixIcon,
//             prefixIcon: icon,
//             suffixIconColor: MyColor.turcoiseColor,
//             hintText: hintText,
//             hintStyle: TextStyle(fontSize: 14.sp, color: MyColor.subtitleTextColor, fontWeight: FontWeight.w300),
//             hoverColor: MyColor.turcoiseColor,
//             border: border,
//             counterText: "",
//             filled: true,
//             enabledBorder: border,
//             focusedBorder: border,
//             errorText: errorText,
//
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// OutlineInputBorder borderStyle = OutlineInputBorder(
//   borderRadius: BorderRadius.circular(10),
//   borderSide: const BorderSide(color: MyColor.greenColor),
// );











import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/color.dart';
import '../text_widget.dart';

class InfoTextFieldWidget extends StatelessWidget {
  final String title;
  final bool? autoFocus;
  final bool? enabled;
  final TextEditingController textEditingController;
  final bool isPass;
  final String? hintText;
  final String? initialValue;
  final TextStyle? hintStyle;
  final TextInputType? textInputType;
  final Icon? icon;
  final Widget? suffixIcon;
  final int? maxLines;
  final FormFieldValidator<String?>? validator;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final TextCapitalization? textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final Color? fillColor;
  final EdgeInsets? scrollPadding;
  final GlobalKey<FormFieldState>? formFieldKey;
  final GestureTapCallback? onTap;
  final FocusNode? focusNode;
  final Color? errorColor;
  final Color? errorBorder;
  final String? errorText;
  final ValueChanged<String>? onFieldSubmitted;

  const InfoTextFieldWidget(
      {Key? key,
        required this.title,
        required this.textEditingController,
        this.textInputType,
        this.hintText,
        this.icon,
        this.suffixIcon,
        this.isPass = false,
        this.validator,
        this.maxLines,
        this.textInputAction,
        this.maxLength,
        this.autoFocus,
        this.enabled,
        this.initialValue,
        this.hintStyle,
        this.textCapitalization,
        this.inputFormatters,
        this.onChanged,
        this.fillColor,
        this.scrollPadding,
        this.formFieldKey,
        this.onTap,
        this.focusNode,
        this.errorColor,
        this.errorBorder,
        this.errorText,
        this.onFieldSubmitted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.r),
      borderSide: const BorderSide(
          width: 1, color: MyColor.textFieldBorderColor), //<-- SEE HERE
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MyText(text: title, fontSize: 18.h),
        SizedBox(height: 10.h),
        TextFormField(
          focusNode: focusNode,
          style: TextStyle(fontSize: 16.sp, color: MyColor.placeHolderColor),
          initialValue: initialValue,
          enabled: enabled ?? true,
          autofocus: autoFocus ?? false,
          inputFormatters: inputFormatters,
          cursorColor: MyColor.turcoiseColor,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          scrollPadding: scrollPadding ??
              EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16 * 4),
          maxLength: maxLength,
          maxLines: maxLines ?? 1,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          controller: textEditingController,
          onChanged: onChanged,
          textInputAction: textInputAction ?? TextInputAction.next,
          keyboardType: textInputType ?? TextInputType.text,
          obscureText: isPass,
          key: formFieldKey,
          onTap: onTap,
          onFieldSubmitted: onFieldSubmitted,

          decoration: InputDecoration(
            isDense: true,
            fillColor: fillColor ?? MyColor.whiteColor,
            filled: true,
            label: Text(
              title ?? '',
              maxLines: 1,
            ),
            labelStyle: MaterialStateTextStyle.resolveWith(
                  (Set<MaterialState> states) {
                final Color color = states.contains(MaterialState.focused)
                    ? Theme.of(context).colorScheme.outline
                    : MyColor.titleTextColor;
                final FontWeight fontWeight =
                states.contains(MaterialState.selected)
                    ? FontWeight.w600
                    : FontWeight.w400;
                return TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: color,
                    fontFamily: 'Montserrat',
                    fontStyle: FontStyle.normal,
                    fontSize: 15,
                    fontWeight: fontWeight);
              },
            ),
            hintMaxLines: 1,
            suffixIcon: suffixIcon,
            hintText: hintText,
            hintStyle: TextStyle(
                fontSize: 14.sp,
                color: MyColor.subtitleTextColor,
                fontWeight: FontWeight.w300),
            errorStyle: TextStyle(color: (errorColor ?? MyColor.redColor)),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: errorBorder ?? MyColor.redColor),
            ),
            disabledBorder: border,
            prefixIcon: icon,
            suffixIconColor: MyColor.turcoiseColor,
            hoverColor: MyColor.turcoiseColor,
            border: border,
            counterText: "",
            enabledBorder: border,
            focusedBorder: border,
            errorText: errorText,
          ),
          // decoration: InputDecoration(
          //   isDense: true,//
          //   fillColor: enabled ? fillColor : CustomColors.greyBg,
          //   filled: true,//
          //   label: Text(
          //     label ?? '',
          //     maxLines: 1,
          //   ),//
          //   labelStyle: MaterialStateTextStyle.resolveWith(
          //         (Set<MaterialState> states) {
          //       final Color color = states.contains(MaterialState.focused)
          //           ? Theme.of(context).colorScheme.outline
          //           : CustomColors.textFieldColor;
          //       final FontWeight fontWeight =
          //       states.contains(MaterialState.selected)
          //           ? FontWeight.w600
          //           : FontWeight.w400;
          //       return TextStyle(
          //           overflow: TextOverflow.ellipsis,
          //           color: color,
          //           fontFamily: 'Montserrat',
          //           fontStyle: FontStyle.normal,
          //           fontSize: 15,
          //           fontWeight: fontWeight);
          //     },
          //   ),//
          //   hintMaxLines: 1,//
          //   suffixIcon: isSuffexWidget,//
          //   hintText: hintText,//
          //   hintStyle: const TextStyle(
          //       fontFamily: 'Montserrat',
          //       color: CustomColors.textFieldColor,
          //       fontWeight: FontWeight.w400,
          //       fontStyle: FontStyle.normal,
          //       fontSize: 15),//
          //   focusedErrorBorder: errorinputboder(context),
          //   disabledBorder: disableInputboder(context),
          //   enabledBorder: inputboder(context),
          //   focusedBorder: focusInputBoder(context),
          //   errorBorder: errorinputboder(context),
          // )
        ),
      ],
    );
  }
}

OutlineInputBorder borderStyle = OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(color: MyColor.greenColor),
);

