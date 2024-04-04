import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:salarynow/information/cubit/employment_cubit/employment_detail_cubit.dart';
import 'package:salarynow/information/screens/profession_screen/professional_submit.dart';
import 'package:salarynow/widgets/error.dart';
import 'package:salarynow/widgets/information_widgets/info_appbar_widget.dart';
import 'package:salarynow/widgets/loader.dart';
import '../../../utils/snackbar.dart';
import '../../../form_helper/form_helper_cubit/salary_cubit.dart';

class ProfessionalInfoScreen extends StatelessWidget {
  final bool? noHitProfileApi;
  ProfessionalInfoScreen({
    Key? key,
    this.noHitProfileApi = false,
  }) : super(key: key);

  final TextEditingController salaryController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const InfoCustomAppBar(),
      body: BlocProvider(
        create: (context) => EmploymentDetailCubit(),
        child: BlocConsumer<EmploymentDetailCubit, EmploymentDetailState>(
          listener: (context, state) {
            if (state is EmploymentDetailError) {
              MySnackBar.showSnackBar(context, state.error.toString());
            }
          },
          builder: (context, state) {
            if (state is EmploymentDetailLoaded) {
              var resData = state.empDetailModal.responseData;

              return ProfessionalInfoSubmit(
                data: resData,
                nohitProfileApi: noHitProfileApi!,
              );
            } else if (state is EmploymentDetailLoading) {
              return const MyLoader();
            } else {
              return MyErrorWidget(
                onPressed: () {
                  var cubit = EmploymentDetailCubit.get(context);
                  cubit.getEmpDetails();
                },
              );
            }
          },
        ),
      ),
    );
  }
}
