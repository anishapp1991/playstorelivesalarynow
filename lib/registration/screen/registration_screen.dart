import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:salarynow/UpperCaseTextFormatter.dart';
import 'package:salarynow/permission_handler/cubit/location_cubit/location_tracker_cubit.dart';
import 'package:salarynow/registration/cubit/pan_card_validation/pan_card_validation_cubit.dart';
import 'package:salarynow/registration/cubit/registration_cubit.dart';
import 'package:salarynow/splash_screen/cubit/splash_cubit.dart';
import 'package:salarynow/utils/analytics_service.dart';
import 'package:salarynow/utils/bottom_sheet.dart';
import 'package:salarynow/utils/crashlytics_app.dart';
import 'package:salarynow/utils/lottie.dart';
import 'package:salarynow/utils/on_screen_loader.dart';
import 'package:salarynow/utils/validation.dart';
import 'package:salarynow/utils/written_text.dart';
import 'package:salarynow/widgets/calender_widget.dart';
import 'package:salarynow/widgets/information_widgets/info_appbar_widget.dart';
import 'package:salarynow/widgets/information_widgets/info_box_continue_widget.dart';
import 'package:salarynow/widgets/information_widgets/info_textfield_widget.dart';
import 'package:salarynow/widgets/onTap_textfield_icon_widget.dart';
import 'package:salarynow/widgets/text_widget.dart';
import '../../routing/route_path.dart';
import '../../utils/color.dart';
import '../../utils/keyboard_bottom_inset.dart';
import '../../utils/snackbar.dart';
import '../../widgets/dialog_box_widget.dart';
import 'package:salarynow/storage/local_storage.dart';
import 'package:salarynow/storage/local_storage_strings.dart';

class RegistrationScreen extends StatefulWidget {
  final String mobileNumber;
  const RegistrationScreen({Key? key, this.mobileNumber = ""}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();

  static final RegExp notNameRegExp = RegExp('[a-zA-Z]');
  static final RegExp nameRegExp = RegExp('[0-9]');
  static final RegExp noSpecialChar = RegExp("!^[`~!@#%^&*()-_=]+\$");
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode focusNode = FocusNode();
  final FocusNode panfocusNode = FocusNode();

  final ScrollController scrollController = ScrollController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController panCardController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController employmentController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  TextInputType _currentKeyboardType = TextInputType.name;

  String? imei = MyStorage.readData(MyStorageString.imei);

  final smartAuth = SmartAuth();
  String? errorGmail;
  bool isGmailLoading = false;

  // void requestForGmail() async {
  //   final res = await smartAuth.requestHint(
  //     isEmailAddressIdentifierSupported: true,
  //     showAddAccountButton: true
  //   );
  //   if(res != null) {
  //     setState(() {
  //       haveAnyGmail = true;
  //     });
  //     emailController.text = res!.id.toString();
  //     print("email requestHint id: ${res!.id.toString()}");
  //   }else{
  //     setState(() {
  //       haveAnyGmail = false;
  //     });
  //     print("Add New Email");
  //   }
  // }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future requestForGmail() async {
    try {
      setState(() {
        isGmailLoading = true;
      });
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        try {
          final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );
          final User userDetails = (await FirebaseAuth.instance.signInWithCredential(credential)).user!;

          emailController.text = userDetails.email.toString();
          print("email id check: ${userDetails.email.toString()}");
          setState(() {
            isGmailLoading = false;
            errorGmail = "";
          });
          await googleSignIn.signOut();
        } on FirebaseAuthException catch (e) {
          switch (e.code) {
            case "account-exists-with-different-credential":
              setState(() {
                isGmailLoading = false;
                errorGmail = "Please provide another email2";
              });
              break;

            case "null":
              setState(() {
                isGmailLoading = false;
                errorGmail = "Please select email";
              });
              break;
            default:
              setState(() {
                isGmailLoading = false;
                errorGmail = "Please provide another email3";
              });
          }
        }
      } else {
        setState(() {
          isGmailLoading = false;
          errorGmail = "Please select email";
        });
      }
    } catch (error) {
      setState(() {
        isGmailLoading = false;
        errorGmail = "Please provide another email1";
      });
      print('Error signing in: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    AnalyticsService.setCustCurrentScreen("Registration Screen");
    var cubit = RegistrationCubit.get(context);
    cubit.reqLocationPermission();
  }

  String stateId = "";
  String cityId = "";
  String empId = "";

  final GlobalKey<FormFieldState> formFieldKey = GlobalKey();

  bool validatePan = false;
  bool panStatus = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegistrationCubit, RegistrationState>(
      listener: (context, state) {
        if (state is LocationPermissionGranted) {}

        if (state is LocationPermissionDenied) {}

        if (state is RegistrationErrorState) {
          Navigator.pop(context);
          MySnackBar.showSnackBar(context, state.error.toString());
        }
        if (state is RegistrationLoadingState) {
          MyScreenLoader.onScreenLoader(context);
        }
        if (state is RegistrationLoadedState) {
          MyStorage.writeData(MyStorageString.userLoggedIn, true);
          Navigator.pop(context);

          MyDialogBox.successfulRegistration(
              context: context,
              onPressed: () {
                var locationCubit = LocationTrackerCubit.get(context);
                locationCubit.postLocationWithoutResp(
                    mCtx: context, loanNumber: "", location_from: 'Registration', status: 'Registration Page');
              });
        }
        if (state is PinCodeLoadingState) {
          MyScreenLoader.onScreenLoader(context);
        }
        if (state is PinCodeErrorState) {
          Navigator.pop(context);
          MySnackBar.showSnackBar(context, state.error.toString());
        }
        if (state is PinCodeLoadedState) {
          Navigator.pop(context);
          MyKeyboardInset.dismissKeyboard(context);
          stateController.text = state.pinCodeModal.responseData!.state.toString();
          stateId = state.pinCodeModal.responseData!.stateId!;
          cityController.text = state.pinCodeModal.responseData!.city.toString();
          cityId = state.pinCodeModal.responseData!.cityId!;
        }

        /// state

        if (state is StateLoadingState) {
          MyScreenLoader.onScreenLoader(context);
        }
        if (state is StateLoadedState) {
          Navigator.pop(context);
          MyBottomSheet.stateListSheetWidget(
              fieldSelected: stateController.text.trim(),
              stateCode: (value) {
                stateId = value;
                cityId = '';
                cityController.text = '';
              },
              onSelected: (value) {
                stateController.text = value;
              },
              context: context,
              stateList: state.stateModal);
        }
        if (state is StateErrorState) {
          Navigator.pop(context);
          MySnackBar.showSnackBar(context, state.error);
        }

        /// city

        if (state is CityLoadingState) {
          MyScreenLoader.onScreenLoader(context);
        }
        if (state is CityLoadedState) {
          Navigator.pop(context);
          MyBottomSheet.cityListSheetWidget(
              fieldSelected: cityController.text.trim(),
              cityCode: (value) {
                cityId = value;
              },
              onSelected: (value) {
                cityController.text = value;
              },
              context: context,
              cityModal: state.cityModal);
        }
        if (state is CityErrorState) {
          Navigator.pop(context);
          MySnackBar.showSnackBar(context, state.error);
        }

        /// Employment
        if (state is EmpLoadingState) {
          MyScreenLoader.onScreenLoader(context);
        }
        if (state is EmpTypeErrorState) {
          Navigator.pop(context);
          MySnackBar.showSnackBar(context, state.error.toString());
        }

        if (state is EmpTypeLoadedState) {
          Navigator.pop(context);
          MyKeyboardInset.dismissKeyboard(context);
          MyBottomSheet.empTypeSheet(
            fieldSelected: employmentController.text,
            context: context,
            employmentTypeModal: state.employmentTypeModal,
            onSelected: (value) {
              employmentController.text = value;
            },
            empId: (value) {
              empId = value;
            },
          );
        }
      },
      builder: (context, state) {
        mobileNoController.text = widget.mobileNumber;
        return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: const InfoCustomAppBar(
              title: MyWrittenText.registrationText,
              leading: null,
            ),
            body: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Container(
                          padding: EdgeInsets.only(top: 20.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BlocListener<PanCardValidationCubit, PanCardValidationState>(
                                listener: (context, state) {
                                  if (state is PanCardValidationLoading) {
                                    MyScreenLoader.onScreenLoader(context);
                                  }
                                  if (state is PanCardValidationLoaded) {
                                    Navigator.pop(context);
                                    //nameController.text = state.panCardModal.responseData!.data!.fullName!;
                                  }
                                  if (state is PanCardValidationError) {
                                    Navigator.pop(context);
                                    MySnackBar.showSnackBar(context, state.error);
                                    setState(() {
                                      panStatus = false;
                                    });
                                    formFieldKey.currentState?.validate();
                                  }
                                  if (state is PanCardValidationStatus) {
                                    setState(() {
                                      panStatus = state.status;
                                    });
                                  }
                                },
                                child: InfoTextFieldWidget(
                                    autoFocus: true,
                                    focusNode: panfocusNode,
                                    textCapitalization: TextCapitalization.characters,
                                    title: MyWrittenText.panCardNoText1,
                                    hintText: MyWrittenText.enterPanNoText,
                                    textEditingController: panCardController,
                                    formFieldKey: formFieldKey,
                                    maxLength: 10,
                                    textInputType: _currentKeyboardType,
                                    inputFormatters: [UpperCaseTextFormatter()],
                                    validator: (value) => validatePanCard(value!),
                                    onChanged: (value) {
                                      String pattern = r'^[A-Z]{3}[P]{1}[A-Z]{1}[0-9]{4}[A-Z]{1}$';
                                      RegExp regExp = RegExp(pattern);
                                      if (!regExp.hasMatch(value)) {
                                        // return nameController.clear();
                                      }
                                      // else if (value.length == 10) {
                                      //   var cubit = PanCardValidationCubit.get(context);
                                      //   cubit.postPinCode(panCard: value);
                                      // } else {
                                      //   // nameController.clear();
                                      // }

                                      if (value.length == 5 && _currentKeyboardType == TextInputType.name) {
                                        setState(() {
                                          _currentKeyboardType = TextInputType.number;
                                        });
                                        panfocusNode.unfocus();
                                        Future.delayed(const Duration(milliseconds: 300), () {
                                          panfocusNode.requestFocus();
                                        });
                                      } else if (value.length == 4 && _currentKeyboardType == TextInputType.number) {
                                        setState(() {
                                          _currentKeyboardType = TextInputType.name;
                                        });
                                        panfocusNode.unfocus();
                                        Future.delayed(const Duration(milliseconds: 300), () {
                                          panfocusNode.requestFocus();
                                        });
                                      } else if (value.length == 9 && _currentKeyboardType == TextInputType.number) {
                                        setState(() {
                                          _currentKeyboardType = TextInputType.name;
                                        });
                                        panfocusNode.unfocus();
                                        Future.delayed(const Duration(milliseconds: 300), () {
                                          panfocusNode.requestFocus();
                                        });
                                      } else if (value.length == 8 && _currentKeyboardType == TextInputType.name) {
                                        setState(() {
                                          _currentKeyboardType = TextInputType.number;
                                        });
                                        panfocusNode.unfocus();
                                        Future.delayed(const Duration(milliseconds: 300), () {
                                          panfocusNode.requestFocus();
                                        });
                                      }
                                    },
                                    suffixIcon: (panStatus)
                                        ? Transform.scale(
                                            scale: 0.75,
                                            child: Lottie.asset(MyLottie.tickSuccessLottie, height: 4.h, width: 4.w))
                                        : null),
                              ),
                              SizedBox(height: 20.h),
                              InfoTextFieldWidget(
                                // enabled: false,
                                title: MyWrittenText.fullNameText,
                                hintText: MyWrittenText.enterNameText,
                                textEditingController: nameController,
                                textInputType: TextInputType.name,
                                maxLength: 20,
                                textCapitalization: TextCapitalization.characters,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter name';
                                  } else if (value.startsWith("0")) {
                                    return 'Incorrect name format';
                                  } else if (value.trim().isEmpty) {
                                    return 'Only whitespace not allowed';
                                  } else if (value.trimLeft() != value || value.trimRight() != value) {
                                    return 'First and last characters should not be whitespace';
                                  } else if (!RegExp(r'^[A-Za-z\s.]+$').hasMatch(value)) {
                                    return 'Name should only contain letters, spaces, and a single dot';
                                  } else if (value.trim() == ".") {
                                    return 'Name should not start with dot';
                                  } else if (value.contains('..')) {
                                    return 'Name should contain only one dot';
                                  } else if (!RegExp(r'\b\w(?:\.\s\w)?').hasMatch(value!)) {
                                    return 'Dot should only appear after a character';
                                  } else {
                                    List<String> words = value.split(' ');
                                    bool containsWordWithoutDot = words.any(
                                        (word) => word.startsWith('.') || RegExp(r'\b\w*\.\w*\w*\b').hasMatch(word));
                                    if (containsWordWithoutDot) {
                                      return 'Dot should only appear after a character';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.h),
                              InfoTextFieldWidget(
                                  fillColor: MyColor.textFieldFillColor,
                                  enabled: false,
                                  title: MyWrittenText.mobileNoText,
                                  hintText: MyWrittenText.enterMobileNoText,
                                  textEditingController: mobileNoController,
                                  textInputType: TextInputType.number,
                                  validator: (value) {
                                    return null;
                                  },
                                  suffixIcon: Transform.scale(
                                      scale: 0.75,
                                      child: Lottie.asset(MyLottie.tickSuccessLottie, height: 4.h, width: 4.w))),
                              SizedBox(height: 20.h),
                              InfoTextFieldWidget(
                                  onTap: () {
                                    requestForGmail();
                                  },
                                  title: MyWrittenText.emailIDText,
                                  hintText: MyWrittenText.enterEmailText,
                                  textEditingController: emailController,
                                  textInputType: TextInputType.none,
                                  // errorText: (errorGmail != "") ? errorGmail : "",
                                  // errorBorder: (errorGmail != "") ? Colors.red : MyColor.textFieldBorderColor,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter email';
                                    } else if (value.trim().isEmpty) {
                                      return 'Only whitespace not allowed';
                                    } else if (value.startsWith("0")) {
                                      return 'Please enter correct email';
                                    } else if (value.trimLeft() != value || value.trimRight() != value) {
                                      return 'First and last characters should not be whitespace';
                                    } else if (!EmailValidator.validate(value)) {
                                      return "Enter correct email";
                                    }
                                    return null;
                                  },
                                  suffixIcon: isGmailLoading
                                      ? const Padding(
                                          padding: EdgeInsets.all(15.0),
                                          child: SizedBox(
                                            width: 10,
                                            height: 10,
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(MyColor.primaryBlueColor),
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      : /*errorGmail != null && errorGmail!.isNotEmpty
                                    ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      setState(() {
                                        // viewModel.streetController.clear();
                                        // viewModel.isStateDropdownOpen = false;
                                        // viewModel.isStreetNumberEnabled = false;
                                      });
                                    });
                                  },
                                )
                                    :*/
                                      Visibility(visible: false, child: Icon(Icons.clear))),
                              SizedBox(height: 20.h),
                              BlocBuilder<RegistrationCubit, RegistrationState>(
                                builder: (context, state) {
                                  if (state is DatePickerState) {
                                    dobController.text = state.selectedDate;
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      MyCalenderWidget.showIOSCalender(context);
                                    },
                                    child: InfoTextFieldWidget(
                                      enabled: false,
                                      title: MyWrittenText.dOBText,
                                      hintText: MyWrittenText.enterDOBText,
                                      textEditingController: dobController,
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            MyCalenderWidget.showIOSCalender(context);
                                          },
                                          icon: const Icon(
                                            Icons.calendar_month,
                                            color: MyColor.turcoiseColor,
                                          )),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 20.h),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: MyText(
                                  text: MyWrittenText.currentAddressText,
                                  fontSize: 22.sp,
                                  color: MyColor.titleTextColor,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              InfoTextFieldWidget(
                                  autoFocus: false,
                                  focusNode: focusNode,
                                  title: MyWrittenText.pinCodeText,
                                  hintText: MyWrittenText.selectCodeText,
                                  textEditingController: pinCodeController,
                                  textInputType: TextInputType.number,
                                  maxLength: 6,
                                  onTap: () async {
                                    focusNode.requestFocus();
                                    /*scrollController.animateTo(
                                        focusNode.offset.dy,
                                        duration: const Duration(microseconds: 100),
                                        curve: Curves.ease
                                    );*/
                                  },
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: (value) {
                                    if (value!.length != 6) {
                                      return "Enter Pin Code";
                                    } else if (value.length != 6) {
                                      return "Empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onChanged: (value) {
                                    if (value.length == 6) {
                                      MyKeyboardInset.dismissKeyboard(context);
                                      context.read<RegistrationCubit>().postPinCode(pinCode: value);
                                    } else {
                                      stateController.clear();
                                      cityController.clear();
                                    }
                                  }),
                              SizedBox(height: 20.h),
                              GestureDetector(
                                onTap: () {
                                  MyKeyboardInset.dismissKeyboard(context);
                                  context.read<RegistrationCubit>().getState();
                                },
                                child: InfoTextFieldWidget(
                                  enabled: false,
                                  title: MyWrittenText.stateText,
                                  hintText: MyWrittenText.selectStateText,
                                  textEditingController: stateController,
                                  validator: (value) {
                                    if (state is PinCodeLoadedState) {
                                      if (stateController.text.isEmpty) {
                                        return "Fill the details";
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(height: 20.h),
                              GestureDetector(
                                onTap: () {
                                  MyKeyboardInset.dismissKeyboard(context);
                                  context.read<RegistrationCubit>().postCity(stateId: stateId);
                                },
                                child: InfoTextFieldWidget(
                                  enabled: false,
                                  title: MyWrittenText.cityText,
                                  hintText: MyWrittenText.selectCityText,
                                  textEditingController: cityController,
                                  validator: (value) {
                                    if (state is PinCodeLoadedState) {
                                      if (cityController.text.isEmpty) {
                                        return "Fill the details";
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(height: 20.h),
                              GestureDetector(
                                onTap: () {
                                  context.read<RegistrationCubit>().getEmploymentType();
                                },
                                child: InfoTextFieldWidget(
                                  enabled: false,
                                  title: MyWrittenText.employmentTypeText,
                                  textEditingController: employmentController,
                                  hintText: MyWrittenText.selectEmploymentText,
                                  textInputAction: TextInputAction.done,
                                  suffixIcon: const OnTapTextFieldSuffixIconWidget(),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              InfoBoxContinueWidget(
                                onPressed: () {
                                  // final String UTMData = MyStorage.getUTMData() ?? "";
                                  // context.read<SplashCubit>().icubeInstallAndRegisterApp(transaction_id: "$UTMData", goal_id: '7749',goal_name: 'register');

                                  if (_formKey.currentState!.validate()) {
                                    // if (panStatus) {
                                    if (employmentController.text.trim().isNotEmpty) {
                                      context.read<RegistrationCubit>().registerUser(
                                          name: nameController.text.trim(),
                                          pinCode: pinCodeController.text.trim(),
                                          mobile: mobileNoController.text.trim(),
                                          stateLocation: stateId,
                                          cityLocation: cityId,
                                          dob: dobController.text.trim(),
                                          email: emailController.text.trim(),
                                          employmentType: empId,
                                          panCardNo: panCardController.text.trim(),
                                          imei: imei ?? '',
                                          mCtx: context);
                                    } else {
                                      MySnackBar.showSnackBar(context, 'Please Fill Employment Type');
                                    }
                                    // } else {
                                    //   MySnackBar.showSnackBar(
                                    //       context, 'Invalid Pan Number');
                                    // }
                                  }
                                },
                                title: MyWrittenText.register,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  String? validatePanCard(String value) {
    debugPrint("validatePanCard");
    String pattern = r'^[A-Z]{3}[P]{1}[A-Z]{1}[0-9]{4}[A-Z]{1}$';
    RegExp regExp = RegExp(pattern);
    validatePan = false;
    if (value.isEmpty) {
      return 'Please Enter Pancard Number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please Enter Valid Pancard Number';
    } else if (value.length == 10) {
      debugPrint("Pancard Length 10");
      PanCardValidationState state = PanCardValidationCubit.get(context).state;
      if (state is PanCardValidationError) {
        debugPrint("PanCardValidationError: ${state.error}");
        return state.error;
      }
    } else if (!panStatus) {
      return 'Invalid Pancard Number';
    }
    validatePan = true;
    return null;
  }
}
