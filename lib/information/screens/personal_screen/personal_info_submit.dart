import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salarynow/dashboard/cubit/get_selfie_cubit/get_selfie_cubit.dart';
import 'package:salarynow/required_document/cubit/image_cubit.dart';
import '../../../form_helper/network/modal/user_common_modal.dart';
import '../../../profile/cubit/profile_cubit.dart';
import '../../../required_document/cubit/get_doc_cubit/get_document_cubit.dart';
import '../../../required_document/screens/selfie_screen.dart';
import '../../../storage/local_storage.dart';
import '../../../utils/bottom_sheet.dart';
import '../../../utils/color.dart';
import '../../../utils/keyboard_bottom_inset.dart';
import '../../../utils/on_screen_loader.dart';
import '../../../utils/snackbar.dart';
import '../../../utils/validation.dart';
import '../../../utils/written_text.dart';
import '../../../widgets/information_widgets/info_box_continue_widget.dart';
import '../../../widgets/information_widgets/info_textfield_widget.dart';
import '../../../widgets/information_widgets/info_title_widget.dart';
import '../../../widgets/loader.dart';
import '../../../widgets/onTap_textfield_icon_widget.dart';
import '../../../widgets/profile_avatar.dart';
import '../../../widgets/text_widget.dart';
import '../../cubit/update_info_cubit/update_info_cubit.dart';
import 'package:salarynow/information/network/modal/personal_info_modal.dart' as value;

class PersonalInfoSubmit extends StatefulWidget {
  value.ResponseData? data;
  PersonalInfoSubmit({
    this.data,
    Key? key,
  }) : super(key: key);

  @override
  State<PersonalInfoSubmit> createState() => _PersonalInfoSubmitState();
}

class _PersonalInfoSubmitState extends State<PersonalInfoSubmit> {
  final _formKey = GlobalKey<FormState>();
  UserCommonModal? userCommonModal = MyStorage.getUserCommonData();

  bool relationStatus = false;
  final TextEditingController panCardController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController maritalStatusController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController alternateNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController empRelationShip1Controller = TextEditingController();
  final TextEditingController relationName1Controller = TextEditingController();
  final TextEditingController relationMobile1Controller = TextEditingController();
  final TextEditingController empRelationship2Controller = TextEditingController();
  final TextEditingController relationName2Controller = TextEditingController();
  final TextEditingController relationMobile2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    panCardController.text = widget.data!.panNo!;
    fullNameController.text = widget.data!.fullname!;
    genderController.text = widget.data!.gender!;
    maritalStatusController.text = widget.data!.maritalStatus!;
    fatherNameController.text = widget.data!.fatherName!;
    alternateNoController.text = widget.data!.alterMobile!;
    emailController.text = widget.data!.email!;
    relationMobile1Controller.text = widget.data!.relationMobile1!;
    empRelationShip1Controller.text = widget.data!.emprelationship1!;
    relationName1Controller.text = widget.data!.relationName1!;
    relationMobile2Controller.text = widget.data!.relationMobile2!;
    empRelationship2Controller.text = widget.data!.emprelationship2!;
    relationName2Controller.text = widget.data!.relationName2!;
    dobController.text = widget.data!.dob!;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: SingleChildScrollView(
                // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Container(
                  padding: EdgeInsets.only(top: 20.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const InfoTitleWidget(
                        title: MyWrittenText.personalInfoText,
                        subtitle: MyWrittenText.pleaseSubtitleText,
                      ),
                      SizedBox(height: 50.h),
                      SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            BlocBuilder<GetSelfieCubit, GetSelfieState>(
                              builder: (context, state) {
                                if (state is GetSelfieLoaded) {
                                  return state.modal.data!.front!.isEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context, MaterialPageRoute(builder: (context) => const SelfieScreen()));
                                            // var cubit = ImagePickerCubit.get(context);
                                            // cubit.pickImage1('first', ImageSource.camera);
                                          },
                                          child: Column(
                                            children: [
                                              const MyProfileAvatar(),
                                              SizedBox(height: 10.h),
                                              const MyText(text: "Upload Selfie"),
                                            ],
                                          ),
                                        )
                                      : MyProfileAvatar(imageUrl: state.modal.data?.front);
                                }
                                if (state is GetDocumentLoading) {
                                  return CircleAvatar(
                                      radius: 50.r, backgroundColor: MyColor.turcoiseColor, child: const MyLoader());
                                }
                                return Container();
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15.h),
                      SizedBox(height: 15.h),
                      InfoTextFieldWidget(
                        fillColor: MyColor.textFieldFillColor,
                        enabled: false,
                        title: MyWrittenText.panCardNoText,
                        textEditingController: panCardController,
                        hintText: MyWrittenText.enterPanCardNumberText,
                        textInputType: TextInputType.name,
                      ),
                      SizedBox(height: 15.h),
                      InfoTextFieldWidget(
                        enabled: false,
                        fillColor: MyColor.textFieldFillColor,
                        title: MyWrittenText.fullNameText,
                        textEditingController: fullNameController,
                        hintText: MyWrittenText.enterFullNameText,
                        textInputType: TextInputType.name,
                      ),
                      SizedBox(height: 15.h),
                      InfoTextFieldWidget(
                        title: MyWrittenText.fatherName,
                        textEditingController: fatherNameController,
                        hintText: MyWrittenText.enterFatherNameText,
                        textInputType: TextInputType.name,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter father's name";
                          } else if (value.startsWith("0")) {
                            return 'Incorrect name format';
                          } else if (value.trim().isEmpty) {
                            return 'Only whitespace not allowed';
                          } else if (value.trimLeft() != value || value.trimRight() != value) {
                            return 'First and last characters should not be whitespace';
                          } else if (!RegExp(r'^[A-Za-z\s.]+$').hasMatch(value)) {
                            return "Father's Name should only contain letters, spaces, and a single dot";
                          } else if (value.trim() == ".") {
                            return "Father's Name should not start with dot";
                          } else if (value.contains('..')) {
                            return "Father's Name should contain only one dot";
                          } else if (!RegExp(r'\b\w(?:\.\s\w)?').hasMatch(value!)) {
                            return 'Dot should only appear after a character';
                          } else {
                            List<String> words = value.split(' ');
                            bool containsWordWithoutDot =
                                words.any((word) => word.startsWith('.') || RegExp(r'\b\w*\.\w*\w*\b').hasMatch(word));
                            if (containsWordWithoutDot) {
                              return 'Dot should only appear after a character';
                            }
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15.h),
                      InfoTextFieldWidget(
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        title: MyWrittenText.alternateNoText,
                        textEditingController: alternateNoController,
                        hintText: MyWrittenText.enterAltNoText,
                        textInputType: TextInputType.phone,
                        maxLength: 10,
                        validator: (value) => InputValidation.validateNumber(alternateNoController.text.trim()),
                      ),
                      SizedBox(height: 15.h),
                      InfoTextFieldWidget(
                        enabled: false,
                        fillColor: MyColor.textFieldFillColor,
                        title: MyWrittenText.emailIDText,
                        textEditingController: emailController,
                        hintText: MyWrittenText.enterEmailIdText,
                        textInputType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 15.h),
                      InfoTextFieldWidget(
                        enabled: false,
                        fillColor: MyColor.textFieldFillColor,
                        title: MyWrittenText.dOBText,
                        textEditingController: dobController,
                        hintText: MyWrittenText.enterDOBText,
                      ),
                      SizedBox(height: 15.h),
                      GestureDetector(
                        onTap: () {
                          if (userCommonModal?.responseData?.gender! != null) {
                            MyBottomSheet.commonUserModalBottomSheet(
                                fieldSelected: genderController.text.trim(),
                                heading: 'Gender',
                                onSelected: (value) {
                                  genderController.text = value;
                                },
                                context: context,
                                list: userCommonModal!.responseData!.gender!);
                          } else {
                            MySnackBar.showSnackBar(context, "Some Error with Gender Field");
                          }
                        },
                        child: InfoTextFieldWidget(
                          enabled: false,
                          title: MyWrittenText.genderText,
                          textEditingController: genderController,
                          hintText: MyWrittenText.enterGenderText,
                          textInputType: TextInputType.name,
                          suffixIcon: OnTapTextFieldSuffixIconWidget(
                            onPressed: () {},
                          ),
                        ),
                      ),
                      SizedBox(height: 15.h),
                      GestureDetector(
                        onTap: () {
                          if (userCommonModal?.responseData?.gender! != null) {
                            MyBottomSheet.commonUserModalBottomSheet(
                                fieldSelected: maritalStatusController.text.trim(),
                                onSelected: (value) {
                                  maritalStatusController.text = value;
                                },
                                context: context,
                                list: userCommonModal!.responseData!.marital!,
                                heading: 'Marital Status');
                          } else {
                            MySnackBar.showSnackBar(context, "Some Error with Marital Field");
                          }
                        },
                        child: InfoTextFieldWidget(
                          enabled: false,
                          title: MyWrittenText.martialStatusText,
                          textEditingController: maritalStatusController,
                          hintText: MyWrittenText.enterMartialStatusText,
                          textInputType: TextInputType.name,
                          suffixIcon: OnTapTextFieldSuffixIconWidget(
                            onPressed: () {},
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      relationStatus == true
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: "${MyWrittenText.contact} 1",
                                  fontSize: 20.h,
                                  color: MyColor.titleTextColor,
                                ),
                                SizedBox(height: 6.h),
                                GestureDetector(
                                  onTap: () {
                                    MyBottomSheet.relationModalBottomSheet(
                                        relationList: RelationModal.relationList,
                                        fieldSelected: empRelationShip1Controller.text.trim(),
                                        context: context,
                                        onSelected: (value) {
                                          empRelationShip1Controller.text = value;
                                        });
                                  },
                                  child: InfoTextFieldWidget(
                                    enabled: false,
                                    title: MyWrittenText.relationshipText,
                                    textEditingController: empRelationShip1Controller,
                                    hintText: MyWrittenText.enterRelationshipText,
                                    textInputType: TextInputType.name,
                                    suffixIcon: OnTapTextFieldSuffixIconWidget(
                                      onPressed: () {},
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15.h),
                                GestureDetector(
                                  onTap: () async {
                                    PhoneContact? singleContact = await getSingleContactPicker();
                                    if (singleContact != null) {
                                      String mobileNumber = singleContact.phoneNumber!.number!;
                                      String cleanedMobileNumber = mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
                                      relationMobile1Controller.text =
                                          cleanedMobileNumber.substring(cleanedMobileNumber.length - 10);
                                      relationName1Controller.text = singleContact.fullName!;
                                    } else {
                                      MySnackBar.showSnackBar(context, 'Contacts Fetching Error');
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      InfoTextFieldWidget(
                                        enabled: false,
                                        title: MyWrittenText.contactNameText,
                                        textEditingController: relationName1Controller,
                                        hintText: MyWrittenText.enterContactNumberText,
                                        textInputType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                      ),
                                      SizedBox(height: 10.h),
                                      InfoTextFieldWidget(
                                        enabled: false,
                                        title: MyWrittenText.contactNumberText,
                                        textEditingController: relationMobile1Controller,
                                        hintText: MyWrittenText.enterContactNumberText,
                                        textInputType: TextInputType.name,
                                        suffixIcon: OnTapTextFieldSuffixIconWidget(
                                            onPressed: () {}, icon: const Icon(Icons.phone)),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                MyText(
                                  text: "${MyWrittenText.contact} 2",
                                  fontSize: 20.h,
                                  color: MyColor.titleTextColor,
                                ),
                                SizedBox(height: 6.h),
                                InkWell(
                                  onTap: () {
                                    MyBottomSheet.relationModalBottomSheet(
                                        relationList: RelationModal.relationList,
                                        fieldSelected: empRelationship2Controller.text.trim(),
                                        context: context,
                                        onSelected: (value) {
                                          empRelationship2Controller.text = value;
                                        });
                                  },
                                  child: InfoTextFieldWidget(
                                    enabled: false,
                                    title: MyWrittenText.relationshipText,
                                    textEditingController: empRelationship2Controller,
                                    hintText: MyWrittenText.enterRelationshipText,
                                    textInputType: TextInputType.name,
                                    suffixIcon: OnTapTextFieldSuffixIconWidget(
                                      onPressed: () {},
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15.h),
                                GestureDetector(
                                  onTap: () async {
                                    PhoneContact? singleContact = await getSingleContactPicker();
                                    if (singleContact != null) {
                                      String mobileNumber = singleContact.phoneNumber!.number!;
                                      String cleanedMobileNumber = mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
                                      relationMobile2Controller.text =
                                          cleanedMobileNumber.substring(cleanedMobileNumber.length - 10);
                                      relationName2Controller.text = singleContact.fullName!;
                                    } else {
                                      MySnackBar.showSnackBar(context, 'Contacts Fetching Error');
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      InfoTextFieldWidget(
                                        enabled: false,
                                        title: MyWrittenText.contactNameText,
                                        textEditingController: relationName2Controller,
                                        hintText: MyWrittenText.enterContactNumberText,
                                      ),
                                      SizedBox(height: 10.h),
                                      InfoTextFieldWidget(
                                        enabled: false,
                                        title: MyWrittenText.contactNumberText,
                                        textEditingController: relationMobile2Controller,
                                        hintText: MyWrittenText.enterContactNumberText,
                                        textInputType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        suffixIcon: OnTapTextFieldSuffixIconWidget(
                                            onPressed: () {}, icon: const Icon(Icons.phone)),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.h)
                              ],
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (MyKeyboardInset.hideWidgetByKeyboard(context))
            BlocListener<UpdateInfoCubit, UpdateInfoState>(
              listener: (context, state) {
                if (state is UpdatePersonalInfoLoading) {
                  MyScreenLoader.onScreenLoader(context);
                }
                if (state is UpdatePersonalInfoError) {
                  Navigator.pop(context);
                  MySnackBar.showSnackBar(context, state.error.toString());
                }
                if (state is UpdatePersonalInfoLoaded) {
                  Navigator.pop(context);
                  MySnackBar.showSnackBar(context, state.personalDetailsModal.responseMsg.toString());
                  var cubitProfile = ProfileCubit.get(context);
                  cubitProfile.getProfile();
                  Navigator.pop(context);
                }
              },
              child: InfoBoxContinueWidget(onPressed: () {
                if (_formKey.currentState!.validate()) {
                  var updateCubit = UpdateInfoCubit.get(context);
                  updateCubit.updatePersonalDetails(
                    relationStatus: relationStatus,
                    dob: dobController.text.trim(),
                    alterMobile: alternateNoController.text.trim(),
                    fatherName: fatherNameController.text.trim(),
                    fullName: fullNameController.text.trim(),
                    gender: genderController.text.trim(),
                    martialStatus: maritalStatusController.text.trim(),
                    panNo: panCardController.text.trim(),
                    emRelation1: relationStatus == true ? empRelationShip1Controller.text.trim() : '',
                    emRelation2: relationStatus == true ? empRelationship2Controller.text.trim() : '',
                    relationMobile1: relationStatus == true ? relationMobile1Controller.text.trim() : '',
                    relationMobile2: relationStatus == true ? relationMobile2Controller.text.trim() : '',
                    relationName1: relationStatus == true ? relationName1Controller.text.trim() : '',
                    relationName2: relationStatus == true ? relationName2Controller.text.trim() : '',
                  );
                }
              }),
            )
        ],
      ),
    );
  }

  Future<PhoneContact?> getSingleContactPicker() async {
    final PhoneContact contactPicker = await FlutterContactPicker.pickPhoneContact();
    final String contact = contactPicker.fullName!;
    final String phoneNumber = contactPicker.phoneNumber!.number.toString();
    if (contact.isNotEmpty && phoneNumber.isNotEmpty) {
      return contactPicker;
    }
    return null;
  }
}
