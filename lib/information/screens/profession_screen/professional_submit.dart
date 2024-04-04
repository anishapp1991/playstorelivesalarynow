import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:salarynow/information/cubit/employment_cubit/loan_emp_cubit.dart';
import 'package:salarynow/profile/cubit/profile_cubit.dart';
import 'package:salarynow/registration/network/modal/employment_type.dart';
import '../../../form_helper/form_helper_cubit/form_helper_cubit.dart';
import '../../../form_helper/form_helper_cubit/salary_cubit.dart';
import '../../../form_helper/network/modal/salary_mode.dart';
import '../../../form_helper/network/modal/state_modal.dart';
import '../../../form_helper/network/modal/user_common_modal.dart';
import '../../../storage/local_storage.dart';
import '../../../utils/bottom_sheet.dart';
import '../../../utils/color.dart';
import '../../../utils/keyboard_bottom_inset.dart';
import '../../../utils/on_screen_loader.dart';
import '../../../utils/snackbar.dart';
import '../../../utils/validation.dart';
import '../../../utils/written_text.dart';
import '../../../widgets/calender_widget.dart';
import '../../../widgets/information_widgets/info_box_continue_widget.dart';
import '../../../widgets/information_widgets/info_textfield_widget.dart';
import '../../../widgets/information_widgets/info_title_widget.dart';
import '../../../widgets/onTap_textfield_icon_widget.dart';
import '../../../widgets/text_widget.dart';
import '../../cubit/update_info_cubit/update_info_cubit.dart';
import 'package:salarynow/information/network/modal/emp_detail_modal.dart' as value;

class ProfessionalInfoSubmit extends StatefulWidget {
  final bool nohitProfileApi;
  final value.ResponseData? data;

  ProfessionalInfoSubmit({
    Key? key,
    required this.nohitProfileApi,
    this.data,
  }) : super(key: key);

  @override
  State<ProfessionalInfoSubmit> createState() => _ProfessionalInfoSubmitState();
}

class _ProfessionalInfoSubmitState extends State<ProfessionalInfoSubmit> {
  final _formKey = GlobalKey<FormState>();

  // TextEditingController textEditingController = TextEditingController();

  UserCommonModal? userCommonModal = MyStorage.getUserCommonData();
  StateModal? stateModal = MyStorage.getStateData();
  SalaryModal? salaryModal = MyStorage.getSalaryMode();
  EmploymentTypeModal? employmentTypeModal = MyStorage.getEmploymentType();

  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController companyEmailController = TextEditingController();
  final TextEditingController companyAddressController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController salaryModeController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController salaryDateController = TextEditingController();
  final TextEditingController empTypeController = TextEditingController();

  String stateId = "0";
  String? cityId;
  String salaryModeId = "0";
  String empId = "0";
  bool? salaryChecked;

  @override
  void initState() {
    super.initState();
    companyNameController.text = widget.data!.companyName!;
    designationController.text = widget.data!.designation!;
    companyEmailController.text = widget.data!.workingemail!;
    companyAddressController.text = widget.data!.officeAddress!;
    pinCodeController.text = widget.data!.officePincode!;
    cityController.text = widget.data!.officeCityName!;
    stateId = widget.data!.officeState!;
    cityId = widget.data!.officeCity!;
    stateController.text = widget.data!.officeStateName!;
    salaryController.text = widget.data!.salary!;
    educationController.text = widget.data!.education!;
    salaryModeController.text = widget.data!.salaryModeName!;
    salaryModeId = widget.data!.salaryMode!;
    empId = widget.data!.employmentType!;
    empTypeController.text = widget.data!.employmentTypeName!;
    salaryChecked = widget.data!.microStatus!;
    String formattedDate = widget.data!.salaryDate!;
    salaryDateController.text = formattedDate;

    double salary = salaryController.text.trim().isNotEmpty ? double.parse(salaryController.text.trim()) : -1;
    context.read<SalaryCubit>().checkApprovalStatus(salary);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const InfoTitleWidget(
                        subtitle: MyWrittenText.pleaseSubtitleText,
                        title: MyWrittenText.professionalInfoText,
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          InfoTextFieldWidget(
                            title: MyWrittenText.companyNameText,
                            textEditingController: companyNameController,
                            hintText: MyWrittenText.enterCompanyNameText,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter company name';
                              } else if (value.trim().isEmpty) {
                                return 'Only whitespace not allowed';
                              } else if (value.trimLeft() != value || value.trimRight() != value) {
                                return 'First and last characters should not be whitespace';
                              } else if (!RegExp(r'^[A-Za-z\s.]+$').hasMatch(value)) {
                                return "Company Name should only contain letters, spaces, and a single dot";
                              } else if (value.trim() == ".") {
                                return 'Company Name should not start with dot';
                              } else if (value.contains('..')) {
                                return 'Company Name should contain only one dot';
                              } else if (!RegExp(r'\b\w(?:\.\s\w)?').hasMatch(value!)) {
                                return 'Dot should only appear after a character';
                              } else {
                                List<String> words = value.split(' ');
                                bool containsWordWithoutDot = words
                                    .any((word) => word.startsWith('.') || RegExp(r'\b\w*\.\w*\w*\b').hasMatch(word));
                                if (containsWordWithoutDot) {
                                  return 'Dot should only appear after a character';
                                }
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15.h),
                          InfoTextFieldWidget(
                            autoFocus: false,
                            title: MyWrittenText.designationText,
                            textEditingController: designationController,
                            hintText: MyWrittenText.enterDesignationText,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter designation name';
                              } else if (value.trim().isEmpty) {
                                return 'Only whitespace not allowed';
                              } else if (value.trimLeft() != value || value.trimRight() != value) {
                                return 'First and last characters should not be whitespace';
                              } else if (!RegExp(r'^[A-Za-z\s.]+$').hasMatch(value)) {
                                return "Designation Name should only contain letters, spaces, and a single dot";
                              } else if (value.trim() == ".") {
                                return 'Designation Name should not start with dot';
                              } else if (value.contains('..')) {
                                return 'Designation Name should contain only one dot';
                              } else if (!RegExp(r'\b\w(?:\.\s\w)?').hasMatch(value!)) {
                                return 'Dot should only appear after a character';
                              } else {
                                List<String> words = value.split(' ');
                                bool containsWordWithoutDot = words
                                    .any((word) => word.startsWith('.') || RegExp(r'\b\w*\.\w*\w*\b').hasMatch(word));
                                if (containsWordWithoutDot) {
                                  return 'Dot should only appear after a character';
                                }
                              }
                              return null;
                            },
                          ),
                          // =>validateNameField(widget.designationController.text.trim(), "Designation Name")),
                          SizedBox(height: 15.h),
                          InfoTextFieldWidget(
                              title: MyWrittenText.companyEmailIDText,
                              textEditingController: companyEmailController,
                              hintText: MyWrittenText.enterCompanyEmailIDText,
                              textInputType: TextInputType.emailAddress,
                              validator: (value) => InputValidation.emailValidation(value!)),
                          SizedBox(height: 15.h),
                          // InfoTextFieldWidget(
                          //     maxLength: 4,
                          //     title: MyWrittenText.workingMonthText,
                          //     textEditingController: widget.workingMonthController,
                          //     hintText: MyWrittenText.enterWorkingMonthText,
                          //     textInputType: TextInputType.number,
                          //     validator: (value) {
                          //       RegExp regExp = RegExp(r'^0.*');
                          //       if (widget.workingMonthController.text.trim().isEmpty) {
                          //         return 'This Field is Empty';
                          //       } else if (regExp.hasMatch(widget.workingMonthController.text)) {
                          //         return 'Enter Correct Month';
                          //       } else {
                          //         return null;
                          //       }
                          //     }),
                          SizedBox(height: 15.h),
                          InfoTextFieldWidget(
                              title: MyWrittenText.companyAddressText,
                              textEditingController: companyAddressController,
                              hintText: MyWrittenText.enterCompanyAddressText,
                              validator: (value) => InputValidation.addressValidation(companyAddressController.text)),
                          SizedBox(height: 15.h),
                          BlocListener<FormHelperApiCubit, FormHelperApiState>(
                            listener: (context, state) {
                              if (state is PinCodeeLoadedState) {
                                pinCodeController.text = state.pinCodeModal.responseData!.pincode!;
                                cityController.text = state.pinCodeModal.responseData!.city!;
                                stateController.text = state.pinCodeModal.responseData!.state!;
                                stateId = state.pinCodeModal.responseData!.stateId!;
                                cityId = state.pinCodeModal.responseData!.cityId!;
                              }
                            },
                            child: InfoTextFieldWidget(
                                title: MyWrittenText.pinCodeeText,
                                textEditingController: pinCodeController,
                                hintText: MyWrittenText.enterPinCodeText,
                                textInputType: TextInputType.number,
                                maxLength: 6,
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
                                    context.read<FormHelperApiCubit>().postPinCode(pinCode: value);
                                  } else {
                                    stateController.clear();
                                    cityController.clear();
                                  }
                                }),
                          ),
                          SizedBox(height: 15.h),
                          GestureDetector(
                              onTap: () {
                                if (stateModal != null) {
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
                                      stateList: stateModal!);
                                } else {
                                  MySnackBar.showSnackBar(context, 'Some Error on State Field');
                                }
                              },
                              child: InfoTextFieldWidget(
                                enabled: false,
                                title: MyWrittenText.stateText,
                                textEditingController: stateController,
                                hintText: MyWrittenText.enterStateText,
                                suffixIcon: OnTapTextFieldSuffixIconWidget(onPressed: () {}),
                              )),
                          SizedBox(height: 15.h),
                          BlocListener<FormHelperApiCubit, FormHelperApiState>(
                            listener: (context, state) {
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
                            },
                            child: GestureDetector(
                                onTap: () {
                                  var cubit = FormHelperApiCubit.get(context);
                                  cubit.postCity(stateId: stateId);
                                },
                                child: InfoTextFieldWidget(
                                  enabled: false,
                                  title: MyWrittenText.cityText,
                                  textEditingController: cityController,
                                  hintText: MyWrittenText.enterCityText,
                                  suffixIcon: OnTapTextFieldSuffixIconWidget(onPressed: () {}),
                                )),
                          ),
                          SizedBox(height: 15.h),
                          BlocBuilder<SalaryCubit, bool>(
                            builder: (context, state) {
                              return Column(
                                children: [
                                  InfoTextFieldWidget(
                                      autoFocus: false,
                                      maxLength: 7,
                                      title: MyWrittenText.salaryText,
                                      textEditingController: salaryController,
                                      textInputType: TextInputType.phone,
                                      hintText: MyWrittenText.enterSalaryText,
                                      validator: (value) {
                                        if (empTypeController.text != "Non-Salaried") {
                                          context.read<SalaryCubit>().checkApprovalStatus(0.0);
                                          RegExp regExp = RegExp(r'^0.*');
                                          if (value!.isEmpty) {
                                            return 'Please enter amount';
                                          } else if (value.trim().isEmpty) {
                                            return 'Only whitespace not allowed';
                                          } else if (value.startsWith("0")) {
                                            return 'Please enter correct amount';
                                          } else if (value.trimLeft() != value || value.trimRight() != value) {
                                            return 'First and last characters should not be whitespace';
                                          } else if (regExp.hasMatch(value) || RegExp(r'[^\w\s]').hasMatch(value)) {
                                            return 'Enter Correct Amount';
                                          } else {
                                            double salary = double.parse(value!);
                                            context.read<SalaryCubit>().checkApprovalStatus(salary);
                                          }
                                        }
                                        return null;
                                      }),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 15.h),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (userCommonModal?.responseData?.qualification! != null) {
                                    MyBottomSheet.educationBottomSheet(
                                        fieldSelected: educationController.text.trim(),
                                        context: context,
                                        qualification: userCommonModal!.responseData!.qualification!,
                                        onSelected: (data) {
                                          educationController.text = data;
                                        });
                                  } else {
                                    MySnackBar.showSnackBar(context, "Some Error with Gender Field");
                                  }
                                },
                                child: InfoTextFieldWidget(
                                  enabled: false,
                                  title: MyWrittenText.educationText,
                                  textEditingController: educationController,
                                  hintText: MyWrittenText.enterEduText,
                                  suffixIcon: OnTapTextFieldSuffixIconWidget(onPressed: () {}),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15.h),
                          GestureDetector(
                            onTap: () {
                              if (salaryModal != null) {
                                MyBottomSheet.salaryBottomSheet(
                                    fieldSelected: salaryModeController.text.trim(),
                                    context: context,
                                    salaryModal: salaryModal!,
                                    salaryCode: (value) {
                                      salaryModeId = value;
                                    },
                                    onSelected: (value) {
                                      salaryModeController.text = value;
                                    });
                              } else {
                                MySnackBar.showSnackBar(context, "Error with salary Mode Field");
                              }
                            },
                            child: InfoTextFieldWidget(
                              enabled: false,
                              title: MyWrittenText.modeOfSalaryText,
                              textEditingController: salaryModeController,
                              hintText: MyWrittenText.enterModeSalaryText,
                              suffixIcon: OnTapTextFieldSuffixIconWidget(onPressed: () {}),
                            ),
                          ),
                          SizedBox(height: 15.h),
                          BlocListener<FormHelperApiCubit, FormHelperApiState>(
                            listener: (context, state) {
                              if (state is DatePickerLoaded) {
                                salaryDateController.text = state.selectedDate;
                                // salaryDateController.text = getDate()!;
                              }
                            },
                            child: GestureDetector(
                              onTap: () {
                                MyCalenderWidget.showSalaryCalender(context);
                              },
                              child: InfoTextFieldWidget(
                                enabled: false,
                                title: MyWrittenText.salaryDateText,
                                textEditingController: salaryDateController,
                                hintText: MyWrittenText.enterSalaryDateText,
                                textInputAction: TextInputAction.done,
                                suffixIcon: const Icon(Icons.calendar_month),
                              ),
                            ),
                          ),
                          SizedBox(height: 15.h),
                          GestureDetector(
                            onTap: () {
                              if (employmentTypeModal != null) {
                                MyBottomSheet.empTypeSheet(
                                    fieldSelected: empTypeController.text.trim(),
                                    context: context,
                                    employmentTypeModal: employmentTypeModal!,
                                    empId: (value) {
                                      empId = value;
                                    },
                                    onSelected: (value) {
                                      empTypeController.text = value;
                                      if (value == "Non-Salaried") {
                                        salaryController.text = "";
                                        context.read<SalaryCubit>().checkApprovalStatus(0.0);
                                      }
                                    });
                              } else {
                                MySnackBar.showSnackBar(context, "Error with Employment Type Field");
                              }
                            },
                            child: InfoTextFieldWidget(
                              enabled: false,
                              title: MyWrittenText.employmentTypeText,
                              textEditingController: empTypeController,
                              hintText: MyWrittenText.enterModeSalaryText,
                              suffixIcon: OnTapTextFieldSuffixIconWidget(onPressed: () {}),
                            ),
                          ),
                          SizedBox(height: 15.h),
                          BlocBuilder<SalaryCubit, bool>(
                            builder: (context, state) {
                              if (state == false) {
                                return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Theme(
                                          data: ThemeData(
                                            unselectedWidgetColor: MyColor.blackColor.withOpacity(0.5), // Your color
                                          ),
                                          child: SizedBox(
                                              height: 20.h,
                                              width: 20.w,
                                              child: Checkbox(
                                                value: salaryChecked,
                                                onChanged: (value) {
                                                  setState(() {
                                                    salaryChecked = value!;
                                                  });
                                                },
                                              ))),
                                      SizedBox(width: 10.w),
                                      Flexible(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (salaryChecked!) {
                                              salaryChecked = false;
                                            } else {
                                              salaryChecked = true;
                                            }
                                            setState(() {});
                                          },
                                          child: MyText(
                                            text: MyWrittenText.salaryCondition,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      )
                                    ]);
                              } else {
                                return const SizedBox();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (MyKeyboardInset.hideWidgetByKeyboard(context))
              BlocListener<UpdateInfoCubit, UpdateInfoState>(
                listener: (context, state) {
                  if (state is UpdateEmpDetailLoading) {
                    MyScreenLoader.onScreenLoader(context);
                  }
                  if (state is UpdateEmpDetailError) {
                    Navigator.pop(context);
                    MySnackBar.showSnackBar(context, state.error.toString());
                  }
                  if (state is UpdateEmpDetailLoaded) {
                    Navigator.pop(context);
                    MySnackBar.showSnackBar(context, state.empDetailModal.responseMsg.toString());
                    if (widget.nohitProfileApi == true) {
                      var loanEmpCubit = LoanEmpCubit.get(context);
                      loanEmpCubit.getEmpDetails();
                    } else {
                      var cubit = ProfileCubit.get(context);
                      cubit.getProfile();
                    }
                    Navigator.pop(context);
                  }
                },
                child: InfoBoxContinueWidget(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      var updateCubit = UpdateInfoCubit.get(context);
                      updateCubit.updateEmpDetails(
                        companyName: companyNameController.text.trim(),
                        designation: designationController.text.trim(),
                        salary: salaryController.text.trim(),
                        salaryMode: salaryModeId,
                        officeAddress: companyAddressController.text.trim(),
                        officeCityId: cityId,
                        officeStateId: stateId,
                        officePinCode: pinCodeController.text.trim(),
                        salaryDate: salaryDateController.text.trim(),
                        education: educationController.text.trim(),
                        workingEmail: companyEmailController.text.trim(),
                        // noMonthWork: widget.workingMonthController.text.trim(),
                        empType: empId,
                        salaryChecked: salaryChecked,
                      );
                    } else {
                      MySnackBar.showSnackBar(context, "Fill Your Details Correctly");
                    }
                  },
                ),
              )
          ],
        ));
  }

  String? getDate() {
    DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(salaryDateController.text);
    String formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
    return formattedDate;
  }
}
