

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salarynow/dashboard/cubit/dashboard_cubit/bankstatement_cubit.dart';
import 'package:salarynow/profile/cubit/profile_cubit.dart';
import 'package:salarynow/routing/bank_statement_arguments.dart';
import 'package:salarynow/routing/route_path.dart';
import 'package:salarynow/utils/color.dart';
import 'package:salarynow/widgets/text_widget.dart';
import '../../bottom_nav_bar/cubit/navbar_cubit.dart';
import '../../utils/images.dart';
import '../../utils/written_text.dart';
import '../../widgets/dashboard_widget/dashboard_list_tile.dart';

class DashBoardInitialWidget extends StatefulWidget {
  const DashBoardInitialWidget({
    super.key,
  });

  @override
  State<DashBoardInitialWidget> createState() => _DashBoardInitialWidgetState();
}

class _DashBoardInitialWidgetState extends State<DashBoardInitialWidget> {
  @override
  void initState() {
    super.initState();
    _initialReload();
  }

  Future<void> _initialReload() async {
    try {
      var dashBoardCubit = BankstatementCubit.get(context);
      await dashBoardCubit.getBankStatementData();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    var profileCubit = ProfileCubit.get(context);
    return Column(
      children: [
        DashBoardListTileOne(
          onPressed: () {
            var cubit = NavbarCubit.get(context);
            cubit.changeBottomNavBar(2);
          },
          title: MyWrittenText.newLoanText,
          image: MyImages.newLoanImage,
          textButtonTitle: MyWrittenText.applyText,
        ),
        DashBoardListTileOne(
          onPressed: () {
            var cubit = NavbarCubit.get(context);
            cubit.changeBottomNavBar(1);
          },
          title: MyWrittenText.calculatorText,
          image: MyImages.calculatorImage,
          textButtonTitle: MyWrittenText.viewText,
        ),
        DashBoardListTileOne(
          onPressed: () {
            var cubit = NavbarCubit.get(context);
            cubit.changeBottomNavBar(4);
          },
          title: MyWrittenText.profileText,
          image: MyImages.profileImage,
          textButtonTitle: MyWrittenText.viewText,
        ),
        SizedBox(height: 15.h),
        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoaded) {
              var data = state.profileModal.responseData;
              if (data!.govtAadhar == true) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RoutePath.govtAadhaarScreen, arguments: {
                      'isApplyScreen': false,
                      'isDashBoardScreen': true,
                      'isNotComeFromRegiScreen': true,
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: MyColor.overdueColor,
                      border: Border.all(color: MyColor.overdueButtonColor),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: "* ",
                                  color: MyColor.redColor,
                                  fontSize: 14.sp,
                                ),
                                Flexible(
                                  child: MyText(
                                    text: "Please Verify your Aadhaar",
                                    // textAlign: TextAlign.justify,
                                    color: MyColor.redColor,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 28.sp,
                              color: MyColor.turcoiseColor,
                            ))
                      ],
                    ),
                  ),
                );
              }
            }
            return const SizedBox();
          },
        ),
        SizedBox(height: 15.h),
        BlocBuilder<BankstatementCubit, BankstatementState>(
          builder: (context, state) {
            if (state is BankstatementLoaded) {
              var data = state!.bankstatementModal!.data!;
              print("data - $data");
              if (data.uploadstatus) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RoutePath.bankStatementScreen,
                        arguments: BankStatementArguments(
                          refreshProfile: () {
                            profileCubit.getProfile();
                          },
                          stackCount: 2, // Add your second argument here
                        ));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: MyColor.overdueColor,
                      border: Border.all(color: MyColor.overdueButtonColor),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 8,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      text: "* ",
                                      color: MyColor.redColor,
                                      fontSize: 14.sp,
                                    ),
                                    Flexible(
                                      child: MyText(
                                        text: data.showmessage!,
                                        // textAlign: TextAlign.justify,
                                        color: MyColor.redColor,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.upload,
                              color: MyColor.turcoiseColor,
                              size: 30.sp,
                            ))
                      ],
                    ),
                  ),
                );
              }
            }
            return const SizedBox();
          },
        ),
        SizedBox(height: 15.h),
      ],
    );
  }
}
