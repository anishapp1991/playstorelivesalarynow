import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salarynow/login/network/modal/loginVRCallBackModal.dart';
import 'package:salarynow/login/network/modal/loginVerifyCallModal.dart';
import 'package:salarynow/service_helper/api/dio_api.dart';
import 'package:salarynow/service_helper/error_helper.dart';
import 'package:salarynow/storage/local_user_modal.dart';
import 'package:salarynow/utils/crashlytics_app.dart';
import 'package:salarynow/utils/written_text.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../service_helper/modal/error_modal.dart';
import '../../storage/local_storage.dart';
import '../network/api/auth_api.dart';
import '../network/modal/loginVerifyModal.dart';
import '../network/modal/login_modal.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  static LoginCubit get(context) => BlocProvider.of(context);

  final api = AuthApi(DioApi(isHeader: false).sendRequest);

  Future loginUser({required String mobileNumber, required String imei, required bool isLoginPage}) async {
    try {
      emit(LoginLoadingState());
      var appSignatureID = await SmsAutoFill().getAppSignature;
      print("appSignatureID - $appSignatureID");
      final res = await api.loginUser({'mobile': mobileNumber, 'imei': imei, 'code': appSignatureID});
      if (res.response.statusCode == 200) {
        LoginModal model = LoginModal.fromJson(res.data);
        if (isLoginPage) {
          emit(LoginLoadedState(model));
        } else {
          emit(LoginLoadedOtpState(model));
        }
      } else {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(LoginErrorState(errorModal.responseMsg.toString()));
      }
    } on DioError catch (e, stack) {
      CrashlyticsApp().setUserIdentifier(mobileNumber);
      CrashlyticsApp().log('DioError:loginUser:- ${e.message}');
      CrashlyticsApp().setCustomKey('mobile', mobileNumber);
      CrashlyticsApp().recordError(e, stack);
      emit(LoginErrorState(handleDioError(e).toString()));
    } catch (e, stack) {
      CrashlyticsApp().setUserIdentifier(mobileNumber);
      CrashlyticsApp().log('Other Error:loginUser:- $e');
      CrashlyticsApp().setCustomKey('mobile', mobileNumber);
      CrashlyticsApp().recordError(e, stack);

      emit(LoginErrorState(MyWrittenText.somethingWrong));
    }
  }

  Future verifyUser({required String mobileNumber, required String otp}) async {
    try {
      emit(OtpLoadingState());
      final res = await api.verifyUser({'mobile': mobileNumber, 'otp': otp});

      if (res.response.statusCode == 200) {
        LoginVerifyModal model = LoginVerifyModal.fromJson(res.data);
        MyStorage.setUserData(LocalUserModal.fromJson(res.data));
        emit(OtpLoadedState(loginVerifyModal: model));
      } else if (res.response.statusCode == 400) {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(OtpErrorState(errorModal.responseMsg.toString()));
      }
    } on DioError catch (e, s) {
      CrashlyticsApp().setUserIdentifier(mobileNumber);
      CrashlyticsApp().log('DioError:verifyUser:- ${e.message}');
      CrashlyticsApp().setCustomKey('ErrorType', 'DioError');
      CrashlyticsApp().recordError(e, s);

      emit(OtpErrorState(handleDioError(e).toString()));
    } catch (e, s) {
      CrashlyticsApp().setUserIdentifier(mobileNumber);
      CrashlyticsApp().log('Other Error:verifyUser:- $e');
      CrashlyticsApp().setCustomKey('ErrorType', 'OtherError');
      CrashlyticsApp().recordError(e, s);

      emit(OtpErrorState(MyWrittenText.somethingWrong));
    }
  }

  Future verifyByCallUser({required String mobileNumber}) async {
    try {
      emit(OtpLoadingState());
      final res = await api.verifyByCallUser({'mobile': mobileNumber});

      if (res.response.statusCode == 200) {
        LoginVerifyCallModal model = LoginVerifyCallModal.fromJson(res.data);
        emit(CallVerifyLoadedState(loginVerifyCallModal: model));
      } else if (res.response.statusCode == 400) {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(OtpErrorState(errorModal.responseMsg.toString()));
      }
    } on DioError catch (e, s) {
      CrashlyticsApp().setUserIdentifier(mobileNumber);
      CrashlyticsApp().log('DioError:verifyUser:- ${e.message}');
      CrashlyticsApp().setCustomKey('ErrorType', 'DioError');
      CrashlyticsApp().recordError(e, s);

      emit(OtpErrorState(handleDioError(e).toString()));
    } catch (e, s) {
      CrashlyticsApp().setUserIdentifier(mobileNumber);
      CrashlyticsApp().log('Other Error:verifyUser:- $e');
      CrashlyticsApp().setCustomKey('ErrorType', 'OtherError');
      CrashlyticsApp().recordError(e, s);

      emit(OtpErrorState(MyWrittenText.somethingWrong));
    }
  }

  Future checkVRCallBack({required String mobileNumber, required String callersid}) async {
    await Future.delayed(Duration(seconds: 5));
    try {
      // emit(OtpLoadingState());
      final res = await api.callIVRCallback({'mobile': mobileNumber, 'callersid': callersid});

      if (res.response.statusCode == 200) {
        print("res.data ::: ${res.data}");
        LoginVrCallBackModal model = LoginVrCallBackModal.fromJson(res.data);
        emit(CallVerifyCallBackLoadedState(loginVrCallBackModal: model, callersid: callersid));
      } else if (res.response.statusCode == 400) {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(VRCallErrorState(errorModal.responseMsg.toString(), callersid));
      }
    } on DioError catch (e, s) {
      CrashlyticsApp().setUserIdentifier(mobileNumber);
      CrashlyticsApp().log('DioError:verifyUser:- ${e.message}');
      CrashlyticsApp().setCustomKey('ErrorType', 'DioError');
      CrashlyticsApp().recordError(e, s);

      emit(VRCallErrorState(handleDioError(e).toString(), callersid));
    } catch (e, s) {
      CrashlyticsApp().setUserIdentifier(mobileNumber);
      CrashlyticsApp().log('Other Error:verifyUser:- $e');
      CrashlyticsApp().setCustomKey('ErrorType', 'OtherError');
      CrashlyticsApp().recordError(e, s);

      emit(VRCallErrorState(MyWrittenText.somethingWrong, callersid));
    }
  }

  static const platform = MethodChannel('com.app.salarynow/channel');

  void verifyCall({String? mobileNo = ""}) async {
    try {
      emit(CallVerifyLoadingState());
      var status = await platform.invokeMethod('clickCallVerify', {"mobileNo": mobileNo});
      var exotel_status = status["status"];
      var exotel_res = status["msg"];
      print("Call Log Status ::: ${status["status"]}, ${status["msg"]}");

      final res = await api.callExotelStatus({'mobile': mobileNo, 'status': exotel_status, 'exotel_res': exotel_res});
      print("api respo ::: ${res.response.data}");
      if (res.response.statusCode == 200) {
        LoginVerifyModal model = LoginVerifyModal.fromJson(res.data);
        MyStorage.setUserData(LocalUserModal.fromJson(res.data));
        emit(OtpLoadedState(loginVerifyModal: model));
      } else if (res.response.statusCode == 400) {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(OtpErrorState(errorModal.responseMsg.toString()));
      }
    } on DioError catch (e, s) {
      CrashlyticsApp().setUserIdentifier(mobileNo!);
      CrashlyticsApp().log('DioError:verify Call User:- ${e.message}');
      CrashlyticsApp().setCustomKey('ErrorType', 'DioError');
      CrashlyticsApp().recordError(e, s);

      emit(OtpErrorState(handleDioError(e).toString()));
    } catch (e, s) {
      CrashlyticsApp().setUserIdentifier(mobileNo!);
      CrashlyticsApp().log('Other Error:verify Call User:- $e');
      CrashlyticsApp().setCustomKey('ErrorType', 'OtherError');
      CrashlyticsApp().recordError(e, s);

      emit(OtpErrorState(MyWrittenText.somethingWrong));
    }
  }
}
