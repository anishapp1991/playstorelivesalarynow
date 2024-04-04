import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pinput/pinput.dart';
import 'package:salarynow/login/cubit/login_cubit.dart';
import 'package:salarynow/login/cubit/timer_cubit/timer_cubit.dart';
import 'package:salarynow/storage/local_storage.dart';
import 'package:salarynow/storage/local_storage_strings.dart';
import 'package:salarynow/utils/images.dart';
import 'package:salarynow/utils/on_screen_loader.dart';
import 'package:salarynow/utils/written_text.dart';
import 'package:salarynow/widgets/text_widget.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../utils/color.dart';
import '../../permission_handler/cubit/all_permission_cubit/permission_cubit.dart';
import '../../routing/route_path.dart';
import '../../utils/keyboard_bottom_inset.dart';
import '../../utils/snackbar.dart';
import '../../widgets/dialog_box_widget.dart';
import '../../widgets/elevated_button_widget.dart';
import '../../widgets/logo_image_widget.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  final String imei;

  const OtpScreen({
    Key? key,
    this.mobileNumber = "",
    this.imei = "",
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
  final TextEditingController _pinPutController = TextEditingController();
  String otpNumber = "";

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 22,
      color: Color.fromRGBO(30, 60, 87, 1),
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: MyColor.turcoiseColor),
    ),
  );

  @override
  void initState() {
    super.initState();
    initCallMethodUsingChannel();
    var permissionCubit = PermissionCubit.get(context);
    permissionCubit.reqSMSPermission();
    listenOtp();
    showCallOption();
  }

  String codeValue = "";
  bool codeReceived = false, showCallText = false, VRCallVerifyApi = false;

  @override
  void codeUpdated() {
    print("Update code $code");
    setState(() {
      _pinPutController.text = "$code";
      codeReceived = true;
    });
  }

  showCallOption() {
    Future.delayed(Duration(seconds: 10), () {
      if (!codeReceived) {
        setState(() {
          showCallText = true;
        });
      }
    });
  }

  startCallVerifyCheckCallbackApi() {
    Future.delayed(Duration(seconds: 60), () {
      setState(() {
        VRCallVerifyApi = true;
      });
    });
  }

  static const platform = MethodChannel('com.app.salarynow/channel');

  void initCallMethodUsingChannel() async {
    await platform.invokeMethod('initialize');
  }

  void listenOtp() async {
    await SmsAutoFill().unregisterListener();
    listenForCode();
    await SmsAutoFill().listenForCode;
    print("OTP listen Called");
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    print("unregisterListener");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is OtpErrorState) {
          Navigator.pop(context);
          MySnackBar.showSnackBar(context, state.error.toString());
        }
        if (state is OtpLoadingState) {
          MyScreenLoader.onScreenLoader(context);
        }
        if (state is OtpLoadedState) {
          MyDialogBox.successfulRegistration(context: context, onPressed: () {});
          //Navigator.pop(context);

          Future.delayed(Duration(seconds: 2), () {
            /// Response 0 is for New User and 1 for the Login user
            if (state.loginVerifyModal.responseStatus == 0) {
              Navigator.pushNamedAndRemoveUntil(
                  context, RoutePath.registrationScreen, arguments: widget.mobileNumber, (route) => false);
            } else {
              MyStorage.writeData(MyStorageString.userLoggedIn, true);
              Navigator.pushNamedAndRemoveUntil(context, RoutePath.botNavBar, (route) => false);
            }
          });
        }

        if (state is CallVerifyLoadingState) {
          MyCallLoadingLoader.onScreenCallLoading(context);
        }

        /// Call Verify Api Response
        if (state is CallVerifyLoadedState) {
          // Navigator.pop(context);

          if (state.loginVerifyCallModal.responseStatus == 1) {
            startCallVerifyCheckCallbackApi();
            context.read<LoginCubit>().checkVRCallBack(
                mobileNumber: widget.mobileNumber, callersid: state.loginVerifyCallModal.responseData!.callersid!);
          } else {
            MySnackBar.showSnackBar(context, 'Please Check Your Mobile Number And Try Again.');
          }
        }

        /// Check callback of the verify by call
        if (state is CallVerifyCallBackLoadedState) {
          if (state.loginVrCallBackModal.responseData == "pending") {
            // MySnackBar.showSnackBar(context, 'Call Received Now ::: ${state.loginVrCallBackModal.responseData}');
            if (!VRCallVerifyApi) {
              context
                  .read<LoginCubit>()
                  .checkVRCallBack(mobileNumber: widget.mobileNumber, callersid: state.callersid!);
            } else {
              MySnackBar.showSnackBar(context, 'Too Many Times Call Try After Sometime.2');
            }
          } else {
            Navigator.pop(context);
            MySnackBar.showSnackBar(context,
                'hello, Please Check Your Mobile Number And Try Again. ${state.loginVrCallBackModal.responseData}');
          }
        }

        if (state is VRCallErrorState) {
          if (!VRCallVerifyApi) {
            context.read<LoginCubit>().checkVRCallBack(mobileNumber: widget.mobileNumber, callersid: state.callersid!);
          } else {
            MySnackBar.showSnackBar(context, 'Too Many Times Call Try After Sometime.1');
          }
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 30.h),
            child: Column(
              children: [
                if (MyKeyboardInset.hideWidgetByKeyboard(context)) const Center(child: MyLogoImageWidget()),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 400.h,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20.r), color: Colors.white, boxShadow: [
                      BoxShadow(
                        color: MyColor.subtitleTextColor.withOpacity(0.2), //New
                        blurRadius: 10.0,
                      )
                    ]),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                      child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  text: MyWrittenText.verifyNumberText, color: MyColor.titleTextColor, fontSize: 30.sp),
                              SizedBox(height: 5.h),
                              Wrap(
                                children: [
                                  MyText(
                                      text: '${MyWrittenText.sixDigitOTPText} ',
                                      color: MyColor.subtitleTextColor,
                                      fontSize: 16.sp),
                                  MyText(
                                      text: '+91 ${widget.mobileNumber}',
                                      color: MyColor.subtitleTextColor,
                                      fontSize: 16.sp),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Pinput(
                          // androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
                          listenForMultipleSmsOnAndroid: true,
                          onCompleted: (value) {
                            context
                                .read<LoginCubit>()
                                .verifyUser(mobileNumber: widget.mobileNumber, otp: value.toString());
                          },
                          onChanged: (value) {
                            otpNumber = value;
                            print("onCodeChanged $code");
                            setState(() {
                              codeValue = code.toString();
                            });
                          },
                          length: 6,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                          controller: _pinPutController,
                          autofocus: true,
                          focusedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: MyColor.turcoiseColor),
                            ),
                          ),
                          submittedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              // color: fillColor,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: MyColor.turcoiseColor),
                            ),
                          ),
                          defaultPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              color: MyColor.subtitleTextColor.withOpacity(0.3),
                              // color: fillColor,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: MyColor.subtitleTextColor.withOpacity(0.3)),
                            ),
                          ),
                          errorPinTheme: defaultPinTheme.copyBorderWith(
                            border: Border.all(color: Colors.redAccent),
                          ),
                        ),
                        if (showCallText) SizedBox(height: 10.h),
                        Transform.translate(
                          offset: Offset(0, -10.h),
                          child: BlocProvider(
                            create: (context) => TimerCubit()..startTimer(),
                            child: BlocBuilder<TimerCubit, int>(
                              builder: (context, state) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (state == 0) {
                                          // initSmsListener();
                                          context.read<LoginCubit>().loginUser(
                                              mobileNumber: widget.mobileNumber, imei: widget.imei, isLoginPage: false);
                                          BlocProvider.of<TimerCubit>(context).restartTimer();
                                          _pinPutController.text = "";
                                          setState(() {
                                            showCallText = false;
                                          });
                                        }
                                      },
                                      child: MyText(
                                          text: '${MyWrittenText.resendOTPText} ',
                                          color: state == 0 ? MyColor.turcoiseColor : MyColor.subtitleTextColor,
                                          fontSize: 15.sp),
                                    ),
                                    state == 0
                                        ? const SizedBox()
                                        : MyText(
                                            text: '$state sec',
                                            color: state == 0 ? MyColor.subtitleTextColor : MyColor.turcoiseColor,
                                            fontSize: 15.sp),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        if (showCallText) SizedBox(height: 15.h),
                        Column(
                          children: [
                            if (showCallText)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (widget.mobileNumber.isNotEmpty) {
                                        // context
                                        //     .read<LoginCubit>()
                                        //     .verifyByCallUser(mobileNumber: widget.mobileNumber);

                                        context.read<LoginCubit>().verifyCall(mobileNo: widget.mobileNumber);
                                      } else {
                                        MySnackBar.showSnackBar(
                                            context, 'Please Check Your Mobile Number And Try Again.');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50.0),
                                        side: BorderSide(color: MyColor.turcoiseColor),
                                      ),
                                      backgroundColor: MyColor.whiteColor,
                                    ),
                                    child: Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.call_outlined,
                                            size: 15,
                                            color: MyColor.turcoiseColor,
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            MyWrittenText.verifyByCall,
                                            style: TextStyle(
                                                color: MyColor.turcoiseColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13.h),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: 15.h),
                            MyButton(
                                text: MyWrittenText.verifyText,
                                onPressed: () {
                                  if (otpNumber.isNotEmpty) {
                                    context
                                        .read<LoginCubit>()
                                        .verifyUser(mobileNumber: widget.mobileNumber, otp: otpNumber);
                                  } else {
                                    MySnackBar.showSnackBar(context, 'Please Enter OTP');
                                  }
                                }),
                            SizedBox(height: 15.h),
                            InkWell(
                                onTap: () => Navigator.pop(context),
                                child: MyText(
                                    text: MyWrittenText.changeNumberText,
                                    color: MyColor.turcoiseColor,
                                    fontSize: 15.sp)),
                          ],
                        ),
                      ]),
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
}
