import 'package:device_information/device_information.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salarynow/permission_handler/api/permission_api.dart';
import 'package:salarynow/registration/network/api/registration_api.dart';
import 'package:salarynow/registration/network/modal/employment_type.dart';
import 'package:salarynow/registration/network/modal/registraion_modal.dart';
import 'package:salarynow/service_helper/api/dio_api.dart';
import 'package:salarynow/service_helper/error_helper.dart';
import 'package:salarynow/splash_screen/cubit/splash_cubit.dart';
import 'package:salarynow/storage/local_storage_strings.dart';
import 'package:salarynow/utils/crashlytics_app.dart';
import 'package:salarynow/utils/written_text.dart';
import '../../form_helper/network/modal/city_modal.dart';
import '../../form_helper/network/modal/state_modal.dart';
import '../../service_helper/modal/error_modal.dart';
import '../../storage/local_storage.dart';
import '../../storage/local_user_modal.dart';
import '../network/modal/pin_code_modal.dart';

part 'registration_state.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit() : super(RegistrationInitial());

  static RegistrationCubit get(context) => BlocProvider.of(context);

  final api = RegistrationApi(DioApi(isHeader: false).sendRequest);
  String appID = MyStorage.readData(MyStorageString.uuid);

  Future registerUser({
    required String name,
    required String mobile,
    required String panCardNo,
    required String cityLocation,
    required String stateLocation,
    required String pinCode,
    required String email,
    required String dob,
    required String employmentType,
    required String imei,
    required BuildContext mCtx
  }) async {
    var data = {
      "name": name,
      "mobile": mobile,
      "pan_no": panCardNo,
      "city_location": cityLocation,
      "state_location": stateLocation,
      "pincode_location": pinCode,
      "email": email,
      "dob": dob,
      "employment_type": employmentType,
      "imei": imei,
      "app_id": appID
    };
    try {
      emit(RegistrationLoadingState());
      final res = await api.registerUser(data);
      if (res.response.statusCode == 200) {
        RegistrationModal model = RegistrationModal.fromJson(res.data);
        MyStorage.setUserData(LocalUserModal.fromJson(res.data));

        final bool isUTMRegister = MyStorage.getUTMIRegisterDataUpdated() ?? false;
        if(!isUTMRegister) {
          final String source = MyStorage.getUTMSource() ?? "";
          final String transctionId = MyStorage.getUTMTransactionData() ?? "";
          final String deviceId = await DeviceInformation.deviceIMEINumber ?? "";
          final String installTime = MyStorage.getUTMInstallTime() ?? "";
          final String version = MyStorage.getUTMVersion() ?? "";
          if(source.isNotEmpty && transctionId.isNotEmpty) {
            mCtx.read<SplashCubit>().icubeInstallAndRegisterApp(transaction_id: transctionId,goal_id: '7749',goal_name: MyStorageString.register);
            mCtx.read<SplashCubit>().salaryNowInstallAndRegisterApp(utm_source:source,utm_medium: transctionId,install_time:installTime,device_id:deviceId,  goal_name: MyStorageString.register, app_version:version);
          }
        }

        emit(RegistrationLoadedState(model));
      } else {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(RegistrationErrorState(errorModal.responseMsg.toString()));
      }
    } on DioError catch (e, stack) {
      CrashlyticsApp().setUserIdentifier(mobile);
      CrashlyticsApp().log('DioError Error:registerUser:- $e');
      // CrashlyticsApp().setCustomKey('ErrorType', 'OtherError');
      CrashlyticsApp().recordError(e, stack);
      emit(RegistrationErrorState(handleDioError(e).toString()));
    } catch (e, stack) {
      CrashlyticsApp().setUserIdentifier(mobile);
      CrashlyticsApp().log('Other Error:registerUser:- $e');
      // CrashlyticsApp().setCustomKey('ErrorType', 'OtherError');
      CrashlyticsApp().recordError(e, stack);
      emit(RegistrationErrorState(MyWrittenText.somethingWrong));
    }
  }

  Future postPinCode({required String pinCode}) async {
    try {
      emit(PinCodeLoadingState());
      final res = await api.postPinCode({"pincode": pinCode});

      if (res.response.statusCode == 200) {
        PinCodeModal model = PinCodeModal.fromJson(res.data);
        emit(PinCodeLoadedState(model));
      } else {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(PinCodeErrorState(errorModal.responseMsg.toString()));
      }
    } on DioError catch (e,stack) {
      CrashlyticsApp().log('DioError Error:postPinCode:- $e');
      CrashlyticsApp().setCustomKey('pincode', pinCode);
      CrashlyticsApp().recordError(e, stack);
      emit(PinCodeErrorState(handleDioError(e).toString()));
    } catch (e, stack) {
      CrashlyticsApp().log('Others Error:postPinCode:- $e');
      CrashlyticsApp().setCustomKey('pincode', pinCode);
      CrashlyticsApp().recordError(e, stack);
      emit(PinCodeErrorState(MyWrittenText.somethingWrong));
    }
  }

  /// State List
  Future getState() async {
    try {
      emit(StateLoadingState());
      final res = await api.getState();

      if (res.response.statusCode == 200) {
        StateModal model = StateModal.fromJson(res.data);
        MyStorage.setStateData(model);
        emit(StateLoadedState(model));
      } else {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(StateErrorState(error: errorModal.responseMsg.toString()));
      }
    } on DioError catch (e, stack) {
      CrashlyticsApp().log('DioError :getState register:- $e');
      CrashlyticsApp().recordError(e, stack);
      emit(StateErrorState(error: handleDioError(e).toString()));
    } catch (e, stack) {
      CrashlyticsApp().log('Others Error :getState register:- $e');
      CrashlyticsApp().recordError(e, stack);
      emit(StateErrorState(error: MyWrittenText.somethingWrong));
    }
  }

  /// City Api
  Future postCity({
    String? stateId,
  }) async {
    try {
      emit(CityLoadingState());
      final res = await api.postCityId({"state_id": stateId});
      if (res.response.statusCode == 200) {
        CityModal model = CityModal.fromJson(res.data);
        emit(CityLoadedState(model));
      } else {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(CityErrorState(error: errorModal.responseMsg.toString()));
      }
    } on DioError catch (e,stack) {
      CrashlyticsApp().log('DioError Error:postCity:- $e');
      CrashlyticsApp().setCustomKey('state_id', stateId);
      CrashlyticsApp().recordError(e, stack);
      emit(CityErrorState(error: handleDioError(e).toString()));
    }
  }

  Future getEmploymentType() async {
    try {
      emit(EmpLoadingState());
      final res = await api.getEmploymentType();

      if (res.response.statusCode == 200) {
        EmploymentTypeModal model = EmploymentTypeModal.fromJson(res.data);
        MyStorage.setEmploymentType(model);
        emit(EmpTypeLoadedState(model));
      } else {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(EmpTypeErrorState(errorModal.responseMsg.toString()));
      }
    } on DioError catch (e,stack) {
      CrashlyticsApp().log('DioError Error:getEmploymentType:- $e');
      CrashlyticsApp().recordError(e, stack);
      emit(EmpTypeErrorState(handleDioError(e).toString()));
    } catch (e, stack) {
      CrashlyticsApp().log('Others Error Error:getEmploymentType:- $e');
      CrashlyticsApp().recordError(e, stack);
      emit(EmpTypeErrorState(MyWrittenText.somethingWrong));
    }
  }

  Future<void> reqLocationPermission() async {
    PermissionStatus permissionStatus = await Permission.location.request();
    if (permissionStatus == PermissionStatus.granted) {
      emit(LocationPermissionGranted());
    } else {
      emit(LocationPermissionDenied(denied: 'Location Permission Denied'));
    }
  }


  void setDate(DateTime date) {
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);
    emit(DatePickerState(selectedDate: formattedDate));
  }

  validateDate(String? value) {
    if (value == null || value.isEmpty) {
      emit(DateErrorState(error: 'Please select a date'));
    } else {
      emit(DateErrorState(error: null));
    }
  }

  // Future<void> postLocation({required String loanNumber,required String location_from,required String status,}) async {
  //   emit(LocationTrackerLoading());
  //   PermissionStatus permissionStatus = await Permission.location.request();
  //
  //   if (permissionStatus.isGranted) {
  //     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //     List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
  //     Placemark place = placeMarks[0];
  //
  //     try {
  //       var data = {
  //         "latitude": position.latitude.toString(),
  //         "longitude": position.latitude.toString(),
  //         "address": getCompleteAddress(place: place),
  //         "nooffakeapplication": "None",
  //         "fakeenable": "None",
  //         "status": status,
  //         "location_from": location_from,
  //         "loan_no": loanNumber
  //       };
  //
  //       final res = await apiPer.postLocation(data);
  //
  //       if (res.response.statusCode == 200) {
  //         ErrorModal successModal = ErrorModal.fromJson(res.data);
  //         emit(LocationTrackerLoaded(message: successModal.responseMsg.toString()));
  //       } else {
  //         ErrorModal errorModal = ErrorModal.fromJson(res.data);
  //         emit(LocationTrackerError(errorMessage: errorModal.responseMsg.toString()));
  //       }
  //     } on DioError catch (e) {
  //       emit(LocationTrackerError(errorMessage: handleDioError(e).toString()));
  //     } catch (e) {
  //       emit(LocationTrackerError(errorMessage: MyWrittenText.somethingWrong));
  //     }
  //   } else {
  //     emit(LocationTrackerError(errorMessage: 'Permission denied'));
  //   }
  // }
  //
  //
  // String getCompleteAddress({required Placemark place}) {
  //   return "${place.name!.isNotEmpty ? place.name : ""},"
  //       "${place.street!.isNotEmpty ? place.street : ""},"
  //       "${place.subLocality!.isNotEmpty ? place.subLocality : ""},"
  //       "${place.locality!.isNotEmpty ? place.locality : ""},"
  //       "${place.administrativeArea!.isNotEmpty ? place.administrativeArea : ""},"
  //       "${place.subAdministrativeArea!.isNotEmpty ? place.subAdministrativeArea : ""},"
  //       "${place.postalCode!.isNotEmpty ? place.postalCode : ""},"
  //       "${place.isoCountryCode!.isNotEmpty ? place.isoCountryCode : ""},"
  //       "${place.country!.isNotEmpty ? place.country : ""},"
  //       "${place.thoroughfare!.isNotEmpty ? place.thoroughfare : ""},"
  //       "${place.subThoroughfare!.isNotEmpty ? place.subThoroughfare : ""}";
  // }
}
