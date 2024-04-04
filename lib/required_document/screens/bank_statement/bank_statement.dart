import 'dart:async';
import 'dart:io';
// import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salarynow/required_document/cubit/bank_statement_date/bank_statement_get_modal_cubit.dart';
import 'package:salarynow/required_document/cubit/get_doc_cubit/get_document_cubit.dart';
import 'package:salarynow/required_document/screens/bank_statement/bank_statement_web_view.dart';
import 'package:salarynow/routing/route_path.dart';
import 'package:salarynow/utils/color.dart';
import 'package:salarynow/utils/images.dart';
import 'package:salarynow/utils/written_text.dart';
import 'package:salarynow/widgets/dialog_box_widget.dart';
import 'package:salarynow/widgets/elevated_button_widget.dart';
import 'package:salarynow/widgets/error.dart';
import 'package:salarynow/widgets/information_widgets/info_appbar_widget.dart';
import 'package:salarynow/widgets/information_widgets/info_textfield_widget.dart';
import 'package:salarynow/widgets/information_widgets/info_title_widget.dart';
import 'package:salarynow/widgets/text_widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../utils/on_screen_loader.dart';
import '../../../utils/snackbar.dart';
import '../../../widgets/date_range_dialog_box.dart';
import '../../../widgets/dotted_border_widget.dart';
import '../../../widgets/loader.dart';
import '../../cubit/file_picker_cubit/file_picker_cubit.dart';
import '../../cubit/req_doc_cubit/req_document_cubit.dart';

class BankStatement extends StatefulWidget {
  final Function? refreshSalary;
  final int? stackCount;

  const BankStatement({Key? key, this.refreshSalary, this.stackCount}) : super(key: key);

  @override
  State<BankStatement> createState() => _BankStatementState();
}

class _BankStatementState extends State<BankStatement> {
  File? file;
  String? extension;
  String? base64String;
  String? startDate;
  String? endDate;
  String? password;
  String checkInt = "";

  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    var cubit = GetDocumentCubit.get(context);
    cubit.getDocument(doctype: 'bank_statement');
    var bankDate = BankStatementGetCubit.get(context);
    bankDate.getDate();
    FilePickerCubit.get(context).reset();
  }

  Timer? debounce;
  bool isloading = false;
  void onPasswordChanged(String value) {
    if (value != "") {
      setState(() {
        isloading = true;
      });
      if (debounce?.isActive ?? false) debounce!.cancel();
      debounce = Timer(Duration(milliseconds: 500), () {
        setState(() {
          isloading = false;
          isFileOpen = false;
          checkInt = value;
        });
      });
    } else {
      setState(() {
        isloading = false;
      });
    }
  }

  bool fileIsProtected = false;
  resetValue() {
    setState(() {
      controller.text = "";
      isFileOpen = false;
      fileIsProtected = false;
      checkInt = "";
    });
  }

  bool isFileOpen = false;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InfoCustomAppBar(
          title: MyWrittenText.bankStatementText, centerTitle: false, navigatePopNumber: widget.stackCount),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 30.w,
            vertical: 20.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              BlocBuilder<BankStatementGetCubit, BankStatementGetState>(
                builder: (context, state) {
                  var cubit = FilePickerCubit.get(context);
                  if (state is BankStatementGetLoaded) {
                    return Column(
                      children: [
                        state.bankStatementModal.data!.showmessage!.isNotEmpty &&
                                state.bankStatementModal.data!.checkstatus == 1
                            ? ListTile(
                                leading: Icon(
                                  Icons.info_outline,
                                  size: 27.sp,
                                  color: MyColor.placeHolderColor,
                                ),
                                contentPadding: EdgeInsets.zero,
                                title: MyText(
                                  text: state.bankStatementModal.data!.showmessage!.toString(),
                                  fontWeight: FontWeight.w300,
                                  color: MyColor.placeHolderColor,
                                  fontSize: 15,
                                ))
                            : state.bankStatementModal.data!.checkstatus != 1
                                ? ListTile(
                                    leading: Icon(
                                      Icons.info_outline,
                                      size: 27.sp,
                                      color: MyColor.placeHolderColor,
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    title: const MyText(
                                      text: MyWrittenText.bankStateSubTitleText1,
                                      fontWeight: FontWeight.w300,
                                      color: MyColor.placeHolderColor,
                                      fontSize: 15,
                                    ))
                                : SizedBox(),
                        SizedBox(height: 10.h),
                        state.bankStatementModal.data!.uploadpdf == true
                            ? Column(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 15.0, left: 5),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Choose one to continue",
                                          style: TextStyle(
                                            fontSize: 18.0,
                                          )),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => const BankStatementWebView()));
                                    },
                                    child: Card(
                                      elevation: 5,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text("E-Statement",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      // Set your desired text color
                                                      fontSize: 18.0, // Set your desired font size
                                                    )),
                                                Container(
                                                  margin: const EdgeInsets.only(left: 10),
                                                  padding: const EdgeInsets.all(3.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(3.0),
                                                    color: MyColor.greenColor1, // Set your desired background color
                                                  ),
                                                  child: const Text(
                                                    'RECOMMENDED',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      // Set your desired text color
                                                      fontSize: 12.0, // Set your desired font size
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.only(top: 8.0),
                                              child: Text("Instant approval",
                                                  style: TextStyle(
                                                    color: MyColor.placeHolderColor,
                                                    fontWeight: FontWeight.w500,
                                                    // Set your desired text color
                                                    fontSize: 15.0, // Set your desired font size
                                                  )),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 20, bottom: 10),
                                              child: Center(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => const BankStatementWebView()));
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(50.0),
                                                      side: BorderSide(color: MyColor.turcoiseColor),
                                                    ),
                                                    backgroundColor: MyColor.turcoiseColor,
                                                  ),
                                                  child: Container(
                                                    width: 200,
                                                    child: Center(
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            SvgPicture.asset(
                                                              MyImages.uploadIcon,
                                                              fit: BoxFit.fitHeight,
                                                              height: 25.h,
                                                              color: MyColor.whiteColor,
                                                            ),
                                                            SizedBox(width: 8.0),
                                                            // Adjust spacing between icon and text
                                                            Text(
                                                              'E-Statement',
                                                              style: TextStyle(
                                                                  color: MyColor.whiteColor,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 16),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.symmetric(vertical: 25.h),
                                      child: const Align(
                                          alignment: Alignment.center,
                                          child: MyText(
                                            text: "OR",
                                            fontSize: 18,
                                          ))),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          resetValue();
                                          cubit.pickFile(isPdf: true);
                                        },
                                        child: Card(
                                          elevation: 5,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Row(
                                                  children: [
                                                    Text("Upload Statement",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          // Set your desired text color
                                                          fontSize: 18.0, // Set your desired font size
                                                        )),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      '(only PDF)',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        // Set your desired text color
                                                        fontSize: 12.0, // Set your desired font size
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.only(top: 8.0),
                                                  child: Text("Approval will take upto 24 - 48 hours",
                                                      style: TextStyle(
                                                        color: MyColor.placeHolderColor,
                                                        fontWeight: FontWeight.w500,
                                                        // Set your desired text color
                                                        fontSize: 15.0, // Set your desired font size
                                                      )),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                                                  child: Center(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        resetValue();
                                                        cubit.pickFile(isPdf: true);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(50.0),
                                                          side: BorderSide(color: MyColor.turcoiseColor),
                                                        ),
                                                        backgroundColor: MyColor.whiteColor,
                                                      ),
                                                      child: Container(
                                                        width: 200,
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              SvgPicture.asset(
                                                                MyImages.uploadIcon,
                                                                fit: BoxFit.fitHeight,
                                                                height: 25.h,
                                                              ),
                                                              // Replace with your desired icon
                                                              SizedBox(width: 8.0),
                                                              // Adjust spacing between icon and text
                                                              Text(
                                                                'Upload Statement',
                                                                style: TextStyle(
                                                                    color: MyColor.turcoiseColor,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 16),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                    ],
                                  ),
                                  BlocConsumer<FilePickerCubit, FilePickerState>(
                                    listener: (context, state) {
                                      if (state is FilePickerError) {
                                        if (state.error == 'Storage Permission Denied') {
                                          MyDialogBox.openPermissionAppSetting(
                                              context: context,
                                              error: state.error,
                                              onPressed: () =>
                                                  openAppSettings().whenComplete(() => Navigator.pop(context)));
                                        } else {
                                          MySnackBar.showSnackBar(context, state.error);
                                        }
                                      }
                                    },
                                    builder: (context, state) {
                                      return BlocBuilder<FilePickerCubit, FilePickerState>(
                                        builder: (context, state) {
                                          if (state is FilePickerLoading) {
                                            return const MyLoader();
                                          }
                                          if (state is FilePickerSuccess) {
                                            extension = state.extension;
                                            file = state.file;
                                            base64String = state.base64;
                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                if (file != "" && file != null) checkPDF(file, password: checkInt),
                                                MyDottedBorder(
                                                  borderType: BorderType.RRect,
                                                  radius: const Radius.circular(5),
                                                  widget: Container(
                                                    width: double.maxFinite,
                                                    padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                child: Text(
                                                                  "${state.file.path.split("/").last}",
                                                                  style: const TextStyle(
                                                                    fontSize: 15,
                                                                  ),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                resetValue();
                                                                cubit.pickFile(isPdf: true);
                                                              },
                                                              child: const Padding(
                                                                padding: EdgeInsets.only(top: 1.0),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons.edit,
                                                                      color: Colors.green,
                                                                      // Set your icon color
                                                                      size: 15,
                                                                    ),
                                                                    SizedBox(width: 5),
                                                                    Text(
                                                                      "Change File",
                                                                      style: TextStyle(
                                                                        fontSize: 14,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        if (fileIsProtected)
                                                          Container(
                                                            margin: EdgeInsets.symmetric(vertical: 5),
                                                            child: InfoTextFieldWidget(
                                                              textInputType: TextInputType.text,
                                                              textEditingController: controller,
                                                              title: 'Enter Password Here',
                                                              hintText: 'Enter Password Here',
                                                              validator: (value) {
                                                                password = controller.text;
                                                              },
                                                              onChanged: onPasswordChanged,
                                                              // suffixIcon: isloading
                                                              //     ? textfieldLoader()
                                                              //     : (!isloading && isFileOpen)
                                                              //         ? textfieldVerified()
                                                              //         : (controller.text.isNotEmpty)
                                                              //             ? null
                                                              //             : const SizedBox(),
                                                            ),
                                                          ),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                if (startDate != null && endDate != null)
                                                                  Text(
                                                                    "From $startDate To $endDate",
                                                                    style: TextStyle(
                                                                        color: MyColor.subtitleTextColor,
                                                                        fontWeight: FontWeight.w300,
                                                                        fontSize: 13.sp,
                                                                        fontStyle: FontStyle.italic),
                                                                  ),
                                                                // if (password !=
                                                                //     null)
                                                                //   Text(
                                                                //     "Password : $password",
                                                                //     style: TextStyle(
                                                                //         color: MyColor
                                                                //             .subtitleTextColor,
                                                                //         fontWeight:
                                                                //             FontWeight
                                                                //                 .w300,
                                                                //         fontSize: 13
                                                                //             .sp,
                                                                //         fontStyle:
                                                                //             FontStyle.italic),
                                                                //   ),
                                                                if (startDate == null && endDate == null)
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      showDialog(
                                                                          context: context,
                                                                          builder: (_) {
                                                                            return DateRangeDialog(
                                                                              startDate: (data) {
                                                                                startDate = data;
                                                                                setState(() {});
                                                                              },
                                                                              endDate: (data) {
                                                                                endDate = data;
                                                                                setState(() {});
                                                                              },
                                                                              password: (data) {
                                                                                password = data;
                                                                                setState(() {});
                                                                              },
                                                                            );
                                                                          });
                                                                    },
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.only(top: 10.0),
                                                                      child: Row(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.calendar_month,
                                                                            color: MyColor.greenColor,
                                                                            size: 20,
                                                                          ),
                                                                          SizedBox(width: 5.w),
                                                                          MyText(
                                                                            text: "Select Date",
                                                                            fontSize: 16.sp,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                            if (startDate != null && endDate != null)
                                                              GestureDetector(
                                                                onTap: () {
                                                                  showDialog(
                                                                      context: context,
                                                                      builder: (_) {
                                                                        return DateRangeDialog(
                                                                          startDate: (data) {
                                                                            startDate = data;
                                                                            setState(() {});
                                                                          },
                                                                          endDate: (data) {
                                                                            endDate = data;
                                                                            setState(() {});
                                                                          },
                                                                          password: (data) {
                                                                            password = data;
                                                                            setState(() {});
                                                                          },
                                                                        );
                                                                      });
                                                                },
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(top: 2.0),
                                                                  child: Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons.calendar_month,
                                                                        color: MyColor.greenColor,
                                                                        size: 15,
                                                                      ),
                                                                      SizedBox(width: 5.w),
                                                                      MyText(
                                                                        text: "Change Date",
                                                                        fontSize: 14.sp,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 35,
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    SvgPicture.asset(
                                                      MyImages.safeIcon,
                                                      fit: BoxFit.fitHeight,
                                                      height: 15.h,
                                                    ),
                                                    // Replace with your desired icon
                                                    SizedBox(width: 4.0),
                                                    // Adjust spacing between icon and text
                                                    Text(
                                                      MyWrittenText.secureTag,
                                                      style: TextStyle(
                                                          color: MyColor.greenColor1,
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 13),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 20.h),
                                                BlocListener<ReqDocumentCubit, ReqDocumentState>(
                                                    listener: (context, state) {
                                                      if (state is ReqDocumentLoading) {
                                                        MyScreenLoader.onScreenLoader(context);
                                                      }
                                                      if (state is ReqDocumentLoaded) {
                                                        Navigator.pop(context);
                                                        var fileCubit = FilePickerCubit.get(context);
                                                        fileCubit.reset();
                                                        widget.refreshSalary!();
                                                        file = null;
                                                        startDate = null;
                                                        endDate = null;
                                                        password = null;
                                                        MySnackBar.showSnackBar(context, state.modal.responseMsg!);
                                                        var cubit = GetDocumentCubit.get(context);
                                                        cubit.getDocument(doctype: 'bank_statement');
                                                      }
                                                      if (state is ReqDocumentError) {
                                                        Navigator.pop(context);
                                                        MySnackBar.showSnackBar(context, state.error);
                                                      }
                                                    },
                                                    child: MyButton(
                                                      text: 'Continue',
                                                      onPressed: () async {
                                                        if (file != null && startDate != null && endDate != null) {
                                                          if ((fileIsProtected && password != null && password != "") ||
                                                              !fileIsProtected) {
                                                            if (!isFileOpen &&
                                                                (fileIsProtected &&
                                                                    password != null &&
                                                                    password != "")) {
                                                              MySnackBar.showSnackBar(
                                                                  context, "Please Enter Valid Password");
                                                            } else {
                                                              context
                                                                  .read<ReqDocumentCubit>()
                                                                  .postStatement(
                                                                    type: 'bank_statement',
                                                                    file: file!,
                                                                    startDate: startDate,
                                                                    endDate: endDate,
                                                                    password: password ?? "",
                                                                  )
                                                                  .whenComplete(() {});
                                                            }
                                                          } else {
                                                            MySnackBar.showSnackBar(context, "Please Enter Password");
                                                          }
                                                        } else {
                                                          MySnackBar.showSnackBar(
                                                            context,
                                                            file != null ? "Choose Your Start/End Date" : 'Pick a PDF',
                                                          );
                                                        }
                                                      },
                                                    )
                                                    // MyButton(
                                                    //   text: 'Continue',
                                                    //   onPressed: () async   {
                                                    //     if (file != null &&
                                                    //         startDate != null &&
                                                    //         endDate != null) {
                                                    //       if((fileIsProtected && password != null && password != "" ) || !fileIsProtected) {
                                                    //         if((fileIsProtected && password != null && password != "" ))
                                                    //         {
                                                    //           await checkPDF(file, password: password!);
                                                    //         }
                                                    //
                                                    //
                                                    //         if(isFileOpen && (fileIsProtected && password != null && password != "" )) {
                                                    //           print("Valid Password");
                                                    //         }else{
                                                    //           print("Invalid Password");
                                                    //         }
                                                    //
                                                    //
                                                    //         context
                                                    //             .read<
                                                    //             ReqDocumentCubit>()
                                                    //             .postStatement(
                                                    //           type:
                                                    //           'bank_statement',
                                                    //           file: file!,
                                                    //           startDate:
                                                    //           startDate,
                                                    //           endDate:
                                                    //           endDate,
                                                    //           password:
                                                    //           password ??
                                                    //               "",
                                                    //         )
                                                    //             .whenComplete(
                                                    //                 () {});
                                                    //       }else{
                                                    //         MySnackBar.showSnackBar(context, "Please Enter Password");
                                                    //       }
                                                    //     } else {
                                                    //       MySnackBar.showSnackBar(
                                                    //           context,
                                                    //           file != null
                                                    //               ? "Choose Your Start/End Date"
                                                    //               : 'Pick a PDF');
                                                    //     }
                                                    //   },
                                                    // )

                                                    )
                                              ],
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ],
                              )
                            : SizedBox(),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              SizedBox(height: 25.h),
              BlocListener<GetDocumentCubit, GetDocumentState>(
                listener: (context, state) {
                  if (state is BankStatementLoaded) {
                    var bankDate = BankStatementGetCubit.get(context);
                    bankDate.getDate();
                  }
                },
                child: BlocBuilder<GetDocumentCubit, GetDocumentState>(
                  builder: (context, state) {
                    if (state is GetDocumentLoading) {
                      return const MyLoader();
                    } else if (state is BankStatementLoaded) {
                      var data = state.modal.data;
                      return state.modal.data!.isNotEmpty
                          ? Column(
                              children: [
                                // MyText(text: "Your Uploaded PDF List", fontSize: 20.sp),
                                SizedBox(height: 10.h),
                                ListView.builder(
                                    itemCount: data?.length,
                                    shrinkWrap: true,
                                    primary: false,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          // openPDF(data![index].bank_st_full_url!);
                                          // Navigator.pushNamed(
                                          //     context, RoutePath.pdfProtected, arguments: data![index].bank_st_full_url!);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 7.h),
                                          child: MyDottedBorder(
                                            borderType: BorderType.RRect,
                                            radius: const Radius.circular(5),
                                            widget: Padding(
                                              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.h),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                      padding: EdgeInsets.symmetric(vertical: 5.h),
                                                      width: 280.w,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            data![index].bankStatementFile!,
                                                            style: TextStyle(fontSize: 15.sp),
                                                            // color: MyColor.titleTextColor,
                                                          ),
                                                          SizedBox(height: 5.h),
                                                          Text(
                                                            "From ${data[index].fromDate!} To ${data[index].toDate!}",
                                                            style: TextStyle(
                                                                color: MyColor.subtitleTextColor,
                                                                fontWeight: FontWeight.w300,
                                                                fontSize: 13.sp,
                                                                fontStyle: FontStyle.italic),
                                                          ),
                                                        ],
                                                      )),
                                                  const Icon(
                                                    Icons.check_circle,
                                                    color: MyColor.greenColor1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    })
                              ],
                            )
                          : const SizedBox.shrink();
                    } else {
                      return MyErrorWidget(onPressed: () {
                        var cubit = GetDocumentCubit.get(context);
                        cubit.getDocument(doctype: 'bank_statement');
                      });
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget checkPDF(File? file, {String password = ""}) {
    return Container(
      height: 0,
      child: SfPdfViewer.file(
        file!,
        password: password,
        canShowPasswordDialog: false,
        onDocumentLoadFailed: (details) {
          print("Load Failed Details ::: ${details.error},${details.description}");
          if (details.error == "Empty Password Error" ||
              details.description ==
                  "The provided `password` property is empty so unable to load the encrypted document.") {
            setState(() {
              fileIsProtected = true;
            });
          }
        },
        onDocumentLoaded: (details) {
          setState(() {
            isFileOpen = true;
          });
        },
      ),
    );
  }

// late PDFDocument document;
// void openPDF(String url) async {
//   print("pdf url ::: $url");
//   document = await PDFDocument.fromURL(
//     url,
//     cacheManager: CacheManager(
//         Config(
//           "customCacheKey",
//           stalePeriod: const Duration(days: 2),
//           maxNrOfCacheObjects: 10,
//         ),
//       ),
//   );
// }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: InfoCustomAppBar(navigatePopNumber: widget.stackCount),
//     body: SingleChildScrollView(
//       child: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: 30.w,
//           vertical: 20.h,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const InfoTitleWidget(
//               title: MyWrittenText.bankStatementText,
//               subtitle: MyWrittenText.bankStateSubTitleText,
//             ),
//             SizedBox(height: 20.h),
//             ListTile(
//                 leading: Icon(
//                   Icons.info_outline,
//                   size: 30.sp,
//                 ),
//                 contentPadding: EdgeInsets.zero,
//                 title: const MyText(
//                   text: MyWrittenText.bankStateStepOneText,
//                   fontWeight: FontWeight.w300,
//                 )),
//             ListTile(
//               leading: Icon(
//                 Icons.info_outline,
//                 size: 30.sp,
//               ),
//               title: const MyText(
//                 text: MyWrittenText.bankStateStepTwoText,
//                 fontWeight: FontWeight.w300,
//               ),
//               contentPadding: EdgeInsets.zero,
//             ),
//             ListTile(
//               leading: Icon(
//                 Icons.info_outline,
//                 size: 30.sp,
//               ),
//               title: const MyText(
//                 text: MyWrittenText.bankStateStepThreeText,
//                 fontWeight: FontWeight.w300,
//               ),
//               contentPadding: EdgeInsets.zero,
//             ),
//             SizedBox(height: 20.h),
//             BlocBuilder<BankStatementGetCubit, BankStatementGetState>(
//               builder: (context, state) {
//                 if (state is BankStatementGetLoaded) {
//                   return Column(
//                     children: [
//                       state.bankStatementModal.data!.showmessage!.isNotEmpty
//                           ? MyText(
//                         textAlign: TextAlign.center,
//                         color: MyColor.turcoiseColor,
//                         text: state.bankStatementModal.data!.showmessage!.toString(),
//                         fontWeight: FontWeight.w300,
//                       )
//                           : SizedBox(),
//                       SizedBox(height: 20.h),
//                       state.bankStatementModal.data!.uploadpdf == true
//                           ? Column(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(context,
//                                   MaterialPageRoute(builder: (context) => const BankStatementWebView()));
//                             },
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10.r),
//                                 border: Border.all(
//                                   color: MyColor.turcoiseColor,
//                                 ),
//                               ),
//                               width: double.maxFinite,
//                               padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Image.asset(
//                                         MyImages.netBanking,
//                                         width: 50.w,
//                                         fit: BoxFit.fitWidth,
//                                       ),
//                                       SizedBox(width: 10.w),
//                                       Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           MyText(
//                                             text: MyWrittenText.netBankingText,
//                                             fontSize: 20.sp,
//                                             // color: MyColor.titleTextColor,
//                                           ),
//                                           MyText(
//                                             text: MyWrittenText.addPdfStateText,
//                                             color: MyColor.subtitleTextColor,
//                                             fontWeight: FontWeight.w300,
//                                             fontSize: 14.sp,
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                   const Icon(
//                                     Icons.arrow_forward_ios,
//                                     color: MyColor.turcoiseColor,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//
//                           Padding(
//                               padding: EdgeInsets.symmetric(vertical: 25.h),
//                               child: const Align(alignment: Alignment.center, child: MyText(text: "OR"))),
//
//                           BlocConsumer<FilePickerCubit, FilePickerState>(
//                             listener: (context, state) {
//                               if (state is FilePickerError) {
//                                 if (state.error == 'Storage Permission Denied') {
//                                   MyDialogBox.openPermissionAppSetting(
//                                       context: context,
//                                       error: state.error,
//                                       onPressed: () =>
//                                           openAppSettings().whenComplete(() => Navigator.pop(context)));
//                                 } else {
//                                   MySnackBar.showSnackBar(context, state.error);
//                                 }
//                               }
//                             },
//                             builder: (context, state) {
//                               return BlocBuilder<FilePickerCubit, FilePickerState>(
//                                 builder: (context, state) {
//                                   var cubit = FilePickerCubit.get(context);
//                                   if (state is FilePickerLoading) {
//                                     return const MyLoader();
//                                   }
//                                   if (state is FilePickerSuccess) {
//                                     extension = state.extension;
//                                     file = state.file;
//                                     base64String = state.base64;
//                                     return Column(
//                                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                       children: [
//                                         Container(
//                                           padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
//                                           width: double.maxFinite,
//                                           decoration: BoxDecoration(
//                                             border: Border.all(
//                                               color: MyColor.turcoiseColor,
//                                             ),
//                                           ),
//                                           child: Column(
//                                             children: [
//                                               MyText(
//                                                 text: " Your E-Statement Details",
//                                                 fontSize: 16.sp,
//                                               ),
//                                               SizedBox(height: 10.h),
//                                               MyText(
//                                                 text: "Selected File : ${state.file.path.split("/").last}",
//                                                 fontSize: 16.sp,
//                                               ),
//                                               startDate != null
//                                                   ? MyText(
//                                                 text: "Start Date : $startDate",
//                                                 fontSize: 16.sp,
//                                               )
//                                                   : const SizedBox(),
//                                               endDate != null
//                                                   ? MyText(
//                                                 text: "End Date : $endDate",
//                                                 fontSize: 16.sp,
//                                               )
//                                                   : const SizedBox(),
//                                               password != null
//                                                   ? MyText(
//                                                 text: password!.isNotEmpty
//                                                     ? "Password : $password"
//                                                     : "Password : N/A",
//                                                 fontSize: 16.sp,
//                                               )
//                                                   : const SizedBox(),
//                                             ],
//                                           ),
//                                         ),
//                                         GestureDetector(
//                                           onTap: () {
//                                             showDialog(
//                                                 context: context,
//                                                 builder: (_) {
//                                                   return DateRangeDialog(
//                                                     startDate: (data) {
//                                                       startDate = data;
//                                                       setState(() {});
//                                                     },
//                                                     endDate: (data) {
//                                                       endDate = data;
//                                                       setState(() {});
//                                                     },
//                                                     password: (data) {
//                                                       password = data;
//                                                       setState(() {});
//                                                     },
//                                                   );
//                                                 });
//                                           },
//                                           child: Container(
//                                             height: 55.h,
//                                             width: double.maxFinite,
//                                             decoration: BoxDecoration(
//                                               color: MyColor.highLightBlueColor,
//                                               border: Border.all(
//                                                 color: MyColor.turcoiseColor,
//                                               ),
//                                             ),
//                                             child: Padding(
//                                               padding: EdgeInsets.symmetric(horizontal: 10.w),
//                                               child: Row(
//                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                 children: [
//                                                   Row(
//                                                     children: [
//                                                       const Icon(
//                                                         Icons.calendar_month,
//                                                         color: MyColor.greenColor,
//                                                       ),
//                                                       SizedBox(width: 10.w),
//                                                       MyText(
//                                                         text: "Select Date",
//                                                         fontSize: 16.sp,
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   const Icon(
//                                                     Icons.edit,
//                                                     color: MyColor.greenColor,
//                                                   )
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         GestureDetector(
//                                           onTap: () {
//                                             cubit.pickFile(isPdf: true);
//                                           },
//                                           child: Container(
//                                             height: 55.h,
//                                             width: double.maxFinite,
//                                             decoration: BoxDecoration(
//                                               color: MyColor.highLightBlueColor,
//                                               border: Border.all(
//                                                 color: MyColor.turcoiseColor,
//                                               ),
//                                             ),
//                                             child: SizedBox(
//                                               width: double.maxFinite,
//                                               child: Center(
//                                                 child: MyText(
//                                                   text: "Change the PDF",
//                                                   fontSize: 16.sp,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(height: 20.h),
//                                         BlocListener<ReqDocumentCubit, ReqDocumentState>(
//                                             listener: (context, state) {
//                                               if (state is ReqDocumentLoading) {
//                                                 MyScreenLoader.onScreenLoader(context);
//                                               }
//                                               if (state is ReqDocumentLoaded) {
//                                                 Navigator.pop(context);
//                                                 var fileCubit = FilePickerCubit.get(context);
//                                                 fileCubit.reset();
//                                                 widget.refreshSalary!();
//                                                 file = null;
//                                                 startDate = null;
//                                                 endDate = null;
//                                                 password = null;
//                                                 MySnackBar.showSnackBar(context, state.modal.responseMsg!);
//                                                 var cubit = GetDocumentCubit.get(context);
//                                                 cubit.getDocument(doctype: 'bank_statement');
//                                               }
//                                               if (state is ReqDocumentError) {
//                                                 Navigator.pop(context);
//                                                 MySnackBar.showSnackBar(context, state.error);
//                                               }
//                                             },
//                                             child: MyButton(
//                                               text: 'Upload',
//                                               onPressed: () {
//                                                 if (file != null && startDate != null && endDate != null) {
//                                                   context
//                                                       .read<ReqDocumentCubit>()
//                                                       .postStatement(
//                                                     type: 'bank_statement',
//                                                     file: file!,
//                                                     startDate: startDate,
//                                                     endDate: endDate,
//                                                     password: password ?? "",
//                                                   )
//                                                       .whenComplete(() {});
//                                                 } else {
//                                                   MySnackBar.showSnackBar(
//                                                       context,
//                                                       file != null
//                                                           ? "Choose Your Start/End Date"
//                                                           : 'Pick a PDF');
//                                                 }
//                                               },
//                                             ))
//                                       ],
//                                     );
//                                   } else {
//                                     return GestureDetector(
//                                       onTap: () {
//                                         cubit.pickFile(isPdf: true);
//                                       },
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(10.r),
//                                           // color: MyColor.highLightBlueColor,
//                                           border: Border.all(
//                                             color: MyColor.turcoiseColor,
//                                           ),
//                                         ),
//                                         width: double.maxFinite,
//                                         padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
//                                         child: Row(
//                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Image.asset(
//                                                   MyImages.bankStatementImage,
//                                                   width: 50.w,
//                                                   fit: BoxFit.fitWidth,
//                                                 ),
//                                                 SizedBox(width: 10.w),
//                                                 Column(
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   children: [
//                                                     MyText(
//                                                       text: 'Upload Your PDF',
//                                                       fontSize: 20.sp,
//                                                       // color: MyColor.titleTextColor,
//                                                     ),
//                                                     MyText(
//                                                       text: MyWrittenText.addPdfStateText,
//                                                       color: MyColor.subtitleTextColor,
//                                                       fontWeight: FontWeight.w300,
//                                                       fontSize: 14.sp,
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                             const Icon(
//                                               Icons.arrow_forward_ios,
//                                               color: MyColor.turcoiseColor,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                 },
//                               );
//                             },
//                           ),
//
//                           SizedBox(height: 15,),
//                           const MyText(
//                             textAlign: TextAlign.center,
//                             color: MyColor.turcoiseColor,
//                             text: MyWrittenText.quickDisbursalTag,
//                             fontWeight: FontWeight.w300,
//                           )
//
//                         ],
//                       )
//                           : SizedBox(),
//                     ],
//                   );
//                 } else {
//                   return Container();
//                 }
//               },
//             ),
//             SizedBox(height: 25.h),
//             BlocListener<GetDocumentCubit, GetDocumentState>(
//               listener: (context, state) {
//                 if (state is BankStatementLoaded) {
//                   var bankDate = BankStatementGetCubit.get(context);
//                   bankDate.getDate();
//                 }
//               },
//               child: BlocBuilder<GetDocumentCubit, GetDocumentState>(
//                 builder: (context, state) {
//                   if (state is GetDocumentLoading) {
//                     return const MyLoader();
//                   } else if (state is BankStatementLoaded) {
//                     var data = state.modal.data;
//                     return state.modal.data!.isNotEmpty
//                         ? Column(
//                       children: [
//                         MyText(text: "Your Uploaded PDF List", fontSize: 20.sp),
//                         SizedBox(height: 10.h),
//                         ListView.builder(
//                             itemCount: data?.length,
//                             shrinkWrap: true,
//                             primary: false,
//                             itemBuilder: (context, index) {
//                               return Container(
//                                 padding: EdgeInsets.symmetric(vertical: 7.h),
//                                 child: MyDottedBorder(
//                                   widget: Padding(
//                                     padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.h),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Container(
//                                             padding: EdgeInsets.symmetric(vertical: 5.h),
//                                             width: 280.w,
//                                             child: Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 MyText(
//                                                   text: data![index].bankStatementFile!,
//                                                   maxLines: 3,
//                                                 ),
//                                                 SizedBox(height: 10.h),
//                                                 MyText(
//                                                   text:
//                                                   'From ${data[index].fromDate!} To ${data[index].toDate!}',
//                                                   fontSize: 14.sp,
//                                                   fontWeight: FontWeight.w300,
//                                                 ),
//                                               ],
//                                             )),
//                                         CircleAvatar(
//                                           radius: 24.r,
//                                           backgroundColor: MyColor.greenColor,
//                                           child: CircleAvatar(
//                                             radius: 22.r,
//                                             backgroundColor: MyColor.whiteColor,
//                                             child: const Icon(
//                                               Icons.done,
//                                               color: MyColor.greenColor,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             })
//                       ],
//                     )
//                         : const SizedBox.shrink();
//                   } else {
//                     return MyErrorWidget(onPressed: () {
//                       var cubit = GetDocumentCubit.get(context);
//                       cubit.getDocument(doctype: 'bank_statement');
//                     });
//                   }
//                 },
//               ),
//             )
//           ],
//         ),
//       ),
//     ),
//   );
// }
}
