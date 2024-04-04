import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:salarynow/information/screens/residential_screen/residential_info_screen.dart';
import 'package:salarynow/profile/cubit/profile_cubit.dart';
import 'package:salarynow/utils/images.dart';
import 'package:salarynow/utils/keyboard_bottom_inset.dart';
import 'package:salarynow/widgets/elevated_button_widget.dart';
import 'package:salarynow/widgets/information_widgets/info_appbar_widget.dart';
import 'package:salarynow/widgets/text_widget.dart';
import '../../../../login/cubit/timer_cubit/timer_cubit.dart';
import '../../../../routing/route_path.dart';
import '../../../../utils/color.dart';
import '../../../../utils/on_screen_loader.dart';
import '../../../../utils/snackbar.dart';
import '../../../../utils/validation.dart';
import '../../../../utils/written_text.dart';
import '../../../../widgets/information_widgets/info_textfield_widget.dart';
import '../../../cubit/residential_cubit/aadhaar_card_otp/aadhaar_card_otp_cubit.dart';
import '../../../cubit/residential_cubit/aadhaar_card_verification/aadhaar_card_verification_cubit.dart';
import 'package:flutter/src/widgets/framework.dart';

class GovtAadhaarCardVerify extends StatefulWidget {
  final bool isApplyScreen;
  final bool isDashBoardScreen;
  bool isNotComeFromRegiScreen;
  GovtAadhaarCardVerify(
      {Key? key, required this.isDashBoardScreen, required this.isApplyScreen, this.isNotComeFromRegiScreen = true})
      : super(key: key);

  @override
  State<GovtAadhaarCardVerify> createState() => _GovtAadhaarCardVerifyState();
}

class _GovtAadhaarCardVerifyState extends State<GovtAadhaarCardVerify> {
  // ProfileCubit? profileCubit;
  final TextEditingController aadhaarCardController = TextEditingController();
  final TextEditingController pinPutController = TextEditingController();

  String otpNumber = '';
  String clientId = '';
  bool showOtpField = false;
  bool showSkipButton = false;

  final defaultPinTheme = PinTheme(
    margin: EdgeInsets.symmetric(horizontal: 5.w),
    width: 44.w,
    height: 60.h,
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    aadhaarCardController.dispose();
    pinPutController.dispose();
    // profileCubit?.close();
  }

  final GlobalKey<FormFieldState> formFieldKey = GlobalKey();
  int isSkipCount = 0;

  String comingFrom = "";

  @override
  void initState() {
    super.initState();
    if (widget.isDashBoardScreen && widget.isNotComeFromRegiScreen) {
      comingFrom = "DASHBOARD";
    } else if (widget.isDashBoardScreen && !widget.isNotComeFromRegiScreen) {
      comingFrom = "REGISTER";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: InfoCustomAppBar(
          title: 'Aadhaar Verification',
          isNotComeFromRegiScreen: widget.isNotComeFromRegiScreen,
        ),
        body: MultiBlocListener(
          listeners: [
            /// aadhaar Otp Hit
            BlocListener<AadhaarCardOtpCubit, AadhaarCardOtpState>(
              listener: (context, state) {
                if (state is AadhaarCardOtpLoading) {
                  MyScreenLoader.onScreenLoader(context);
                }
                if (state is AadhaarCardOtpLoaded) {
                  Navigator.pop(context);

                  showOtpField = true;
                  // print("Adhar Status - ${state.aadhaarOtpModal.responseData!.statusCode}");
                  /// client Id
                  setState(() {});
                  if (state.aadhaarOtpModal.responseData!.statusCode == 429) {
                    print("clientId - $clientId");
                    if (clientId != "") {
                      MySnackBar.showSnackBar(context, "Use previous OTP or request for a new one after 2 min.",
                          duration: 4);
                    } else {
                      showOtpField = false;
                      MySnackBar.showSnackBar(
                          context, "Previous OTP Session Expired \n Please wait for 2 minutes and try again later.",
                          duration: 4);
                    }
                  } else {
                    clientId = state.aadhaarOtpModal.responseData!.data!.clientId!;
                    MySnackBar.showSnackBar(context, state.aadhaarOtpModal.responseMsg!);
                  }
                  setState(() {});
                  // MyDialogBox.aadhaarOtpDialog(
                  //     pinPutController: _pinPutController,
                  //     context: context,
                  //     clientID: state.aadhaarOtpModal.responseData!.data!.clientId!);
                }
                if (state is AadhaarCardOtpError) {
                  Navigator.pop(context);
                  MySnackBar.showSnackBar(context, state.error);
                  if (state.aadhaarOtpErrorModal?.responseApi != null) {
                    showSkipButton = state.aadhaarOtpErrorModal!.response_skip!;
                    showOtpField = false;
                    print("response_skip - ${state.aadhaarOtpErrorModal!.response_skip!}");
                    setState(() {});
                  }
                }
              },
            ),

            /// aadhaar Otp Verify

            BlocListener<AadhaarCardVerificationCubit, AadhaarCardVerificationState>(
              listener: (context, state) {
                if (state is AadhaarCardVerificationLoading) {
                  MyScreenLoader.onScreenLoader(context);
                }
                if (state is AadhaarCardVerificationLoaded) {
                  Navigator.pop(context);
                  if (widget.isApplyScreen == false) {
                    var cubit = ProfileCubit.get(context);
                    cubit.getProfile();
                  }

                  /// go to residential Screen

                  print(
                      "widget.isDashBoardScree11 ::: ${widget.isDashBoardScreen} , ${widget.isNotComeFromRegiScreen}");
                  if (widget.isDashBoardScreen && widget.isNotComeFromRegiScreen) {
                    Navigator.pop(context);
                  } else if (!widget.isDashBoardScreen && widget.isNotComeFromRegiScreen) {
                    Navigator.pushReplacementNamed(context, RoutePath.residentialScreen);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(context, RoutePath.botNavBar, (route) => false);
                    // Navigator.pushReplacementNamed(context, RoutePath.residentialScreen);
                  }
                  // if (widget.isDashBoardScreen) {
                  //   Navigator.pop(context);
                  // } else {
                  //   Navigator.pushReplacementNamed(context, RoutePath.residentialScreen);
                  // }
                }
                if (state is AadhaarCardVerificationError) {
                  setState(() {
                    isSkipCount++;
                  });
                  MySnackBar.showSnackBar(context, state.error);
                  Navigator.pop(context);
                  formFieldKey.currentState?.validate();
                }
              },
            ),
          ],
          child: GestureDetector(
            onTap: () => MyKeyboardInset.dismissKeyboard(context),
            child: SingleChildScrollView(
              reverse: true,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // if (MyKeyboardInset.hideWidgetByKeyboard(context))
                    // Image.asset(
                    //   MyImages.aadhaarCardImage,
                    //   width: 150.w,
                    //   fit: BoxFit.fitWidth,
                    // ),
                    SizedBox(height: 30.h),
                    InfoTextFieldWidget(
                        textInputType: TextInputType.number,
                        // isPass: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          CardNumberFormatter(),
                        ],
                        title: 'Aadhaar Number/UIDAI',
                        hintText: MyWrittenText.enterAadhaarCardNumberText,
                        textEditingController: aadhaarCardController,
                        formFieldKey: formFieldKey,
                        maxLength: 14,
                        onChanged: (value) {
                          if (value.length == 14) {
                            MyKeyboardInset.dismissKeyboard(context);
                            showOtpField = false;
                            print("showOtpField1 - $showOtpField");
                            AadhaarCardOtpCubit.get(context)
                                .postAadhaarOtp(aadhaarCard: value.replaceAll(' ', ''), comingFrom: comingFrom);
                          } else {
                            /// remove controller
                            // clientId = '';
                            otpNumber = '';
                            showOtpField = false;
                            pinPutController.clear();
                            showSkipButton = false;
                            setState(() {});
                          }
                        },
                        validator: (value) => validateAadhaarCard(value!)),
                    SizedBox(height: 20.h),
                    showOtpField == true
                        ? SizedBox(
                            height: 380.h,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    const MyText(
                                        text: 'Please enter the OTP sent to your UIDAI-registered mobile number'),
                                    SizedBox(height: 20.h),
                                    Pinput(
                                      androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
                                      onCompleted: (value) {
                                        AadhaarCardVerificationCubit.get(context).postAadhaarVerification(
                                          clientID: clientId,
                                          otp: value,
                                        );
                                      },
                                      onChanged: (value) {
                                        otpNumber = value;
                                      },
                                      length: 6,
                                      // onSubmitted: (String pin) {
                                      //   context
                                      //       .read<LoginCubit>()
                                      //       .verifyUser(mobileNumber: widget.mobileNumber, otp: pin.toString());
                                      // },
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],

                                      controller: pinPutController,
                                      // autofocus: true,
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
                                      autofocus: true,
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
                                    SizedBox(height: 20.h),
                                    BlocProvider(
                                      create: (context) => TimerCubit()..startTimer(),
                                      child: BlocBuilder<TimerCubit, int>(
                                        builder: (context, state) {
                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  if (state == 0) {
                                                    AadhaarCardOtpCubit.get(context).postAadhaarOtp(
                                                        aadhaarCard: aadhaarCardController.text.replaceAll(' ', ''));
                                                    BlocProvider.of<TimerCubit>(context).restartTimer();
                                                    pinPutController.text = "";
                                                  }
                                                },
                                                child: MyText(
                                                    text: '${MyWrittenText.resendOTPText} ',
                                                    color:
                                                        state == 0 ? MyColor.turcoiseColor : MyColor.subtitleTextColor,
                                                    fontSize: 15.sp),
                                              ),
                                              state == 0
                                                  ? const SizedBox()
                                                  : MyText(
                                                      text: '$state sec',
                                                      color: state == 0
                                                          ? MyColor.subtitleTextColor
                                                          : MyColor.turcoiseColor,
                                                      fontSize: 15.sp),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                MyButton(
                                    text: 'Confirm',
                                    onPressed: () {
                                      AadhaarCardVerificationCubit.get(context).postAadhaarVerification(
                                        clientID: clientId,
                                        otp: otpNumber,
                                      );
                                    }),
                                if (isSkipCount > 2)
                                  BlocProvider(
                                    create: (context) => TimerCubit.withCustomTime(120)..startTimer(),
                                    child: BlocBuilder<TimerCubit, int>(
                                      builder: (context, state) {
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                print(
                                                    "widget.isDashBoardScree ::: ${widget.isDashBoardScreen} , ${widget.isNotComeFromRegiScreen}");
                                                if (widget.isDashBoardScreen && widget.isNotComeFromRegiScreen) {
                                                  Navigator.pop(context);
                                                } else if (!widget.isDashBoardScreen &&
                                                    widget.isNotComeFromRegiScreen) {
                                                  Navigator.pushReplacementNamed(context, RoutePath.residentialScreen);
                                                } else {
                                                  Navigator.pushNamedAndRemoveUntil(
                                                      context, RoutePath.botNavBar, (route) => false);
                                                  // Navigator.pushReplacementNamed(context, RoutePath.residentialScreen);
                                                }
                                                // if (state == 0) {
                                                //   Navigator.pushNamedAndRemoveUntil(context, RoutePath.botNavBar, (route) => false);
                                                //   // Navigator.pushReplacementNamed(context, RoutePath.residentialScreen);
                                                // }
                                              },
                                              child: MyText(
                                                text: 'Skip ',
                                                color: state == 0 ? MyColor.turcoiseColor : MyColor.subtitleTextColor,
                                                fontSize: 15.sp,
                                              ),
                                            ),
                                            // state == 0
                                            //     ? const SizedBox()
                                            //     : MyText(
                                            //     text: '$state sec',
                                            //     color: state == 0
                                            //         ? MyColor.subtitleTextColor
                                            //         : MyColor.turcoiseColor,
                                            //     fontSize: 15.sp),
                                          ],
                                        );
                                      },
                                    ),
                                  )
                              ],
                            ),
                          )
                        : SizedBox(),
                    showSkipButton
                        ? MyButton(
                            text: 'SKIP',
                            onPressed: () {
                              print(
                                  "widget.isDashBoardScree ::: ${widget.isDashBoardScreen} , ${widget.isNotComeFromRegiScreen}");
                              if (widget.isDashBoardScreen && widget.isNotComeFromRegiScreen) {
                                Navigator.pop(context);
                              } else if (!widget.isDashBoardScreen && widget.isNotComeFromRegiScreen) {
                                Navigator.pushReplacementNamed(context, RoutePath.residentialScreen);
                              } else {
                                Navigator.pushNamedAndRemoveUntil(context, RoutePath.botNavBar, (route) => false);
                                // Navigator.pushReplacementNamed(context, RoutePath.residentialScreen);
                              }
                            })
                        : SizedBox()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validateAadhaarCard(String value) {
    debugPrint("Validate Aadhaar");
    if (value.isEmpty) {
      return "Please Fill This Field";
    } else if (value.length < 12) {
      'Enter Your Aadhaar Correctly';
    } else if (value.length == 14) {
      debugPrint("Validate Aadhaar value.length == 14");
      AadhaarCardOtpState state = AadhaarCardOtpCubit.get(context).state;
      debugPrint("Validate Aadhaar value.length == 14 ${state}");
      if (state is AadhaarCardOtpError) {
        debugPrint("Validate Aadhaar value.length == 14 ${state.error}");
        return state.error;
      }
    }
    return null;
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var inputText = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var bufferString = StringBuffer();
    for (int i = 0; i < inputText.length; i++) {
      bufferString.write(inputText[i]);
      var nonZeroIndexValue = i + 1;
      if (nonZeroIndexValue % 4 == 0 && nonZeroIndexValue != inputText.length) {
        bufferString.write(' ');
      }
    }

    var string = bufferString.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}
