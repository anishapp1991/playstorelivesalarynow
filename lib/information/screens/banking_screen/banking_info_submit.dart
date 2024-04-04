import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salarynow/UpperCaseTextFormatter.dart';
import 'package:salarynow/profile/cubit/profile_cubit.dart';
import '../../../form_helper/form_helper_cubit/bank_list_cubit.dart';
import '../../../form_helper/form_helper_cubit/form_helper_cubit.dart';
import '../../../utils/bottom_sheet.dart';
import '../../../utils/keyboard_bottom_inset.dart';
import '../../../utils/on_screen_loader.dart';
import '../../../utils/snackbar.dart';
import '../../../utils/validation.dart';
import '../../../utils/written_text.dart';
import '../../../widgets/information_widgets/info_box_continue_widget.dart';
import '../../../widgets/information_widgets/info_textfield_widget.dart';
import '../../../widgets/information_widgets/info_title_widget.dart';
import '../../../widgets/onTap_textfield_icon_widget.dart';
import '../../cubit/update_info_cubit/update_info_cubit.dart';
import 'package:salarynow/information/network/modal/banking_detail_modal.dart' as value;

class BankingInfoSubmit extends StatefulWidget {
  value.ResponseData? data;
  BankingInfoSubmit({
    Key? key,
    this.data,
  }) : super(key: key);

  @override
  State<BankingInfoSubmit> createState() => _BankingInfoSubmitState();
}

class _BankingInfoSubmitState extends State<BankingInfoSubmit> {
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController iFSCController = TextEditingController();
  final TextEditingController accNumberController = TextEditingController();
  final TextEditingController reEnterAccNumberController = TextEditingController();
  final TextEditingController branchAddController = TextEditingController();

  String bankID = "";

  @override
  void initState() {
    super.initState();
    bankID = widget.data!.bankid!;
    bankNameController.text = widget.data!.bankName!;
    iFSCController.text = widget.data!.ifsc!;
    accNumberController.text = widget.data!.accountNo!;
    reEnterAccNumberController.text = widget.data!.accountNo!;
    branchAddController.text = widget.data!.branchName!;
  }

  final _formKey = GlobalKey<FormState>();
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
                      title: MyWrittenText.bankingInfoText,
                      subtitle: MyWrittenText.pleaseSubtitleText,
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Column(
                          children: [
                            BlocListener<BankListCubit, BankListState>(
                              listener: (context, state) {
                                if (state is BankListLoadingState) {
                                  MyScreenLoader.onScreenLoader(context);
                                }
                                if (state is BankListLoadedState) {
                                  Navigator.pop(context);
                                  MyBottomSheet.bankBotSheetWidget(
                                      fieldSelected: bankNameController.text.trim(),
                                      onSelected: (data) {
                                        bankNameController.text = data;
                                      },
                                      bankId: (data) {
                                        bankID = data;
                                      },
                                      context: context,
                                      bankListModal: state.bankListModal);
                                }
                                if (state is BankListErrorState) {
                                  Navigator.pop(context);
                                }
                              },
                              child: BlocBuilder<BankListCubit, BankListState>(
                                builder: (context, state) {
                                  return GestureDetector(
                                    onTap: () async {
                                      var cubit = BankListCubit.get(context);
                                      cubit.getBankList();
                                    },
                                    child: InfoTextFieldWidget(
                                      enabled: false,
                                      title: MyWrittenText.bankNameText,
                                      textEditingController: bankNameController,
                                      hintText: MyWrittenText.enterBankNameText,
                                      textInputType: TextInputType.name,
                                      textInputAction: TextInputAction.next,
                                      textCapitalization: TextCapitalization.characters,
                                      suffixIcon: OnTapTextFieldSuffixIconWidget(onPressed: () {}),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 15.h),
                            BlocListener<FormHelperApiCubit, FormHelperApiState>(
                              listener: (context, state) {
                                if (state is IfscLoadingState) {
                                  MyScreenLoader.onScreenLoader(context);
                                }
                                if (state is IfscLoadedState) {
                                  Navigator.pop(context);
                                  iFSCController.text = state.ifscModal.responseData!.ifsc!;
                                  branchAddController.text = state.ifscModal.responseData!.address!;
                                }
                                if (state is IfscErrorState) {
                                  Navigator.pop(context);
                                  MySnackBar.showSnackBar(context, state.error);
                                }
                              },
                              child: InfoTextFieldWidget(
                                textCapitalization: TextCapitalization.characters,
                                maxLength: 11,
                                title: MyWrittenText.iFSCText,
                                textEditingController: iFSCController,
                                hintText: MyWrittenText.enterIFSCText,
                                textInputType: TextInputType.name,
                                inputFormatters: [UpperCaseTextFormatter()],
                                onChanged: (value) {
                                  if (value.length == 11) {
                                    context.read<FormHelperApiCubit>().postIfsc(ifsc: value);
                                  }
                                },
                                validator: (value) {
                                  if (iFSCController.text.trim().isEmpty) {
                                    return "Please Fill This";
                                  } else if (iFSCController.text.trim().length < 11) {
                                    return "Please Fill This";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 15.h),
                            InfoTextFieldWidget(
                                title: MyWrittenText.branchAddressText,
                                textEditingController: branchAddController,
                                hintText: MyWrittenText.enterBranchAddText,
                                textInputType: TextInputType.name,
                                validator: (value) => InputValidation.addressValidation(branchAddController.text)),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        InfoTextFieldWidget(
                          title: MyWrittenText.accNumberText,
                          textEditingController: accNumberController,
                          hintText: MyWrittenText.enterAccNumberText,
                          textInputType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          maxLength: 18,
                          validator: (value) {
                            if (accNumberController.text.trim().isEmpty) {
                              return "Please Fill This";
                            } else if ((value?.length ?? 0) < 9) {
                              return "Account number should range between 9 - 18 digits";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15.h),
                        InfoTextFieldWidget(
                          isPass: true,
                          title: MyWrittenText.reEnterAccNumberText,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textEditingController: reEnterAccNumberController,
                          hintText: MyWrittenText.pleaseReEnterAccNumberText,
                          textInputType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          maxLength: 18,
                          validator: (value) {
                            if (reEnterAccNumberController.text.trim().isEmpty) {
                              return "Please Fill This";
                            } else if ((value?.length ?? 0) < 9) {
                              return "Account number should range between 9 - 18 digits";
                            }
                            return null;
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
                if (state is UpdateBankDetailLoading) {
                  MyScreenLoader.onScreenLoader(context);
                }
                if (state is UpdateBankDetailError) {
                  Navigator.pop(context);
                  MySnackBar.showSnackBar(context, state.error.toString());
                }
                if (state is UpdateBankDetailLoaded) {
                  Navigator.pop(context);
                  MySnackBar.showSnackBar(context, state.bankDetailsModal.responseMsg.toString());
                  var cubitProfile = ProfileCubit.get(context);
                  cubitProfile.getProfile();
                  Navigator.pop(context);
                }
              },
              child: InfoBoxContinueWidget(
                onPressed: () {
                  if (bankNameController.text.isNotEmpty) {
                    if (_formKey.currentState!.validate()) {
                      if (accNumberController.text == reEnterAccNumberController.text) {
                        var updateCubit = UpdateInfoCubit.get(context);
                        updateCubit.updateBankDetails(
                            bankID: bankID,
                            bankName: bankNameController.text.trim(),
                            accountNo: accNumberController.text.trim(),
                            branchName: branchAddController.text.trim(),
                            ifsc: iFSCController.text.trim());
                      } else {
                        MySnackBar.showSnackBar(context, "Account number mismatched");
                      }
                    }
                  } else {
                    MySnackBar.showSnackBar(context, "Please Select Bank Name");
                  }
                },
              ),
            )
        ],
      ),
    );
  }
}
