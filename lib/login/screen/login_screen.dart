import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salarynow/login/cubit/login_cubit.dart';
import 'package:salarynow/permission_handler/cubit/imei_cubit/imei_cubit.dart';
import 'package:salarynow/utils/analytics_service.dart';
import 'package:salarynow/utils/keyboard_bottom_inset.dart';
import 'package:salarynow/utils/on_screen_loader.dart';
import 'package:salarynow/utils/save_logger.dart';
import 'package:salarynow/utils/validation.dart';
import 'package:salarynow/utils/written_text.dart';
import 'package:salarynow/widgets/textField_widget.dart';
import 'package:salarynow/widgets/text_widget.dart';
import '../../routing/route_path.dart';
import '../../utils/color.dart';
import '../../utils/images.dart';
import '../../utils/snackbar.dart';
import '../../widgets/elevated_button_widget.dart';
import '../../widgets/logo_image_widget.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController mobileNumberController = TextEditingController();
  String imei = "";

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        checkPermissionNumber(context);
        break;
      case AppLifecycleState.inactive:
        // SecurityCubit.get(context).close();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> checkPermissionNumber(BuildContext context) async {
    PermissionStatus permissionStatus = await Permission.phone.request();
    if (permissionStatus == PermissionStatus.granted) {
      Navigator.pop(context);
    }
  }

  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    AnalyticsService.setCustCurrentScreen("Login Screen");
    loadLogs();
  }

  void loadLogs() async {
    List<String> loadedLogs = await SaveLogger.getLogs();
    setState(() {
      logs = loadedLogs;
    });
    print("logs :- $logs");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginErrorState) {
            Navigator.pop(context);
            MySnackBar.showSnackBar(context, state.error);
          }
          if (state is LoginLoadingState) {
            MyScreenLoader.onScreenLoader(context);
          }
          if (state is LoginLoadedOtpState) {
            Navigator.pop(context);
            MySnackBar.showSnackBar(context, state.loginModal.responseMsg.toString());
          }
          if (state is LoginLoadedState) {
            Navigator.pop(context);
            MySnackBar.showSnackBar(context, state.loginModal.responseMsg.toString());
            mobileNumberController.clear();
            Navigator.pushNamed(context, RoutePath.otpScreen,
                arguments: {'mobileNumber': state.loginModal.responseData!.mobile!, 'imei': imei});
          }
        },
        child: GestureDetector(
          onTap: () => MyKeyboardInset.dismissKeyboard(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (MyKeyboardInset.hideWidgetByKeyboard(context)) const Center(child: MyLogoImageWidget()),
                  Form(
                    key: _formKey,
                    child: Align(
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
                                    text: MyWrittenText.welcomeText,
                                    fontSize: 30.sp,
                                  ),
                                  MyText(
                                    text: MyWrittenText.loginToContinueText,
                                    color: MyColor.subtitleTextColor,
                                    fontSize: 16.sp,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: MyWrittenText.mobileNumberText,
                                  fontSize: 20.sp,
                                ),
                                MyTextField(
                                  textInputType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  textEditingController: mobileNumberController,
                                  textInputAction: TextInputAction.done,
                                  validator: (value) =>
                                      InputValidation.validateNumber(mobileNumberController.text.trim()),
                                  maxLength: 10,
                                  hintText: MyWrittenText.enterMobileNoText,
                                ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                            BlocListener<ImeiCubit, ImeiState>(
                              listener: (context, state) {
                                if (state is ImeiNumberLoaded) {
                                  imei = state.imeiNumber;
                                  context.read<LoginCubit>().loginUser(
                                      mobileNumber: mobileNumberController.text.trim(), imei: imei, isLoginPage: true);
                                }
                              },
                              child: MyButton(
                                text: MyWrittenText.getOTPText,
                                onPressed: () {
                                  MyKeyboardInset.dismissKeyboard(context);
                                  if (_formKey.currentState!.validate()) {
                                    var cubit = ImeiCubit.get(context);
                                    cubit.getImeiNumber(context, mobileNumberController.text);
                                  }
                                },
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(12.w, 0.h),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, RoutePath.loginContactUsScreen);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const MyText(text: MyWrittenText.helloText),
                          SvgPicture.asset(
                            MyImages.supportIcon,
                            fit: BoxFit.fitHeight,
                            height: 100.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 40.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "We process our loans through RBI Licenced NBFC's Zed Leafin Pvt Ltd & Finkurve Financial Services Limited.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: MyColor.primaryBlueColor),
                        )
                      ],
                    ),
                  )
                  // Padding(
                  //   padding: EdgeInsets.all(16.0),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: logs.map((log) => Text(log)).toList(),
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // void _simulateError() {
  //   try {
  //     throw Exception('Simulated Error By Suraj6666');
  //   } catch (e, stack) {
  //     // Log custom message
  //     FirebaseCrashlytics.instance.log('This is a custom log message. By Suraj6666');
  //
  //     // Set custom keys
  //     FirebaseCrashlytics.instance.setCustomKey('key_1', 'value_1 By Suraj6666');
  //     FirebaseCrashlytics.instance.setCustomKey('key_2', 'value_2 By Suraj6666');
  //
  //     // Set user identifier
  //     FirebaseCrashlytics.instance.setUserIdentifier('user1234');
  //
  //     // Record error
  //     FirebaseCrashlytics.instance.recordError(e, stack);
  //   }
  // }
}
