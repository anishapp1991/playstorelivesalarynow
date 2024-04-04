import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salarynow/dashboard/cubit/get_selfie_cubit/get_selfie_cubit.dart';
import 'package:salarynow/information/cubit/personal_cubit/personal_info_cubit.dart';
import 'package:salarynow/information/screens/personal_screen/personal_info_submit.dart';
import 'package:salarynow/widgets/information_widgets/info_appbar_widget.dart';
import '../../../utils/snackbar.dart';
import '../../../widgets/error.dart';
import '../../../widgets/loader.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({Key? key}) : super(key: key);

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  @override
  void initState() {
    super.initState();
    var getDocCubit = GetSelfieCubit.get(context);
    getDocCubit.getSelfie(doctype: 'selfie');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const InfoCustomAppBar(),
      body: BlocProvider(
        create: (context) => PersonalInfoCubit(),
        child: BlocConsumer<PersonalInfoCubit, PersonalInfoState>(
          listener: (context, state) {
            if (state is PersonalInfoError) {
              MySnackBar.showSnackBar(context, state.error.toString());
            }
          },
          builder: (context, state) {
            if (state is PersonalInfoLoaded) {
              var resData = state.personalDetailsModal.responseData;
              return PersonalInfoSubmit(data: resData);
            } else if (state is PersonalInfoLoading) {
              return const MyLoader();
            } else {
              return MyErrorWidget(
                onPressed: () {
                  var cubit = PersonalInfoCubit.get(context);
                  cubit.getPersonalDetails();
                },
              );
            }
          },
        ),
      ),
    );
  }
}
