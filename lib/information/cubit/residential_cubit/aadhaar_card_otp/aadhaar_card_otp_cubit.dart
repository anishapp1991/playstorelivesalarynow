import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:salarynow/information/network/modal/aadhar_otp_modal.dart';
import 'package:salarynow/utils/crashlytics_app.dart';
import 'package:salarynow/utils/written_text.dart';
import '../../../../service_helper/api/dio_api.dart';
import '../../../../service_helper/error_helper.dart';
import '../../../network/api/residential_api/residential_details_api.dart';
import '../../../network/modal/aadhar_otp_error_modal.dart';

part 'aadhaar_card_otp_state.dart';

class AadhaarCardOtpCubit extends Cubit<AadhaarCardOtpState> {
  AadhaarCardOtpCubit() : super(AadhaarCardOtpInitial());

  static AadhaarCardOtpCubit get(context) => BlocProvider.of(context);

  final api = ResidentialDetailsApi(DioApi(isHeader: true).sendRequest);

  Future postAadhaarOtp({required String aadhaarCard,String comingFrom = ""}) async {
    try {
      emit(AadhaarCardOtpLoading());
      final res = await api.postAadhaarOTP({"aadhaar_number": aadhaarCard,"pagename" : comingFrom});
      if (res.response.statusCode == 200) {

        AadhaarOtpModal model = AadhaarOtpModal.fromJson(res.data);
        if(model.response_skip == false) {
          emit(AadhaarCardOtpLoaded(aadhaarOtpModal: model));

        }else if(model.response_skip == true){
          emit(AadhaarCardOtpSkip(isSkip:true));
        }
      } else if (res.response.statusCode == 400) {

        AadhaarOtpModal aadhaarOtpModal = AadhaarOtpModal.fromJson(res.data);
        if(aadhaarOtpModal.responseData?.statusCode == 429)
        {
          // Rate Limit Wait... for 1 min and then api will able to send sms.
          emit(AadhaarCardOtpLoaded(aadhaarOtpModal: aadhaarOtpModal));
        }else{
          AadhaarOtpErrorModal aadhaarOtpModal = AadhaarOtpErrorModal.fromJson(res.data);
          emit(AadhaarCardOtpError(
              error: aadhaarOtpModal.responseMsg!,
              isAadhaarWorking: aadhaarOtpModal.responseApi!,
              aadhaarOtpErrorModal: aadhaarOtpModal));
        }
      } else {
        AadhaarOtpErrorModal aadhaarOtpModal = AadhaarOtpErrorModal.fromJson(res.data);
        emit(AadhaarCardOtpError(
            error: aadhaarOtpModal.responseMsg!,
            isAadhaarWorking: aadhaarOtpModal.responseApi!,
            aadhaarOtpErrorModal: aadhaarOtpModal));
      }
    } on DioError catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('DioError:postAadhaarOtp:- ${e.message}');
      CrashlyticsApp().setCustomKey('FoundIn', 'postAadhaarOtp');
      CrashlyticsApp().recordError(e, s);

      emit(AadhaarCardOtpError(error: handleDioError(e), isAadhaarWorking: false));
    }
    // catch (e) {
    //   emit(AadhaarCardOtpError(error: MyWrittenText.somethingWrong, isAadhaarWorking: false));
    // }
  }
}
