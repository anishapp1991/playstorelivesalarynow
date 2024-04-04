import 'dart:async';
import 'package:device_information/device_information.dart';
import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salarynow/splash_screen/network/api/splash_api.dart';
import 'package:salarynow/storage/local_storage.dart';
import 'package:salarynow/utils/analytics_service.dart';
import 'package:salarynow/utils/crashlytics_app.dart';
import 'package:salarynow/utils/save_logger.dart';
import '../../dashboard/network/api/dashboard_api.dart';
import '../network/app_status_modal.dart';
import '../../service_helper/api/dio_api.dart';
import '../../service_helper/error_helper.dart';
import '../../service_helper/modal/error_modal.dart';
import '../../storage/local_storage_strings.dart';
import '../../storage/local_user_modal.dart';
part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitialState()) {
    splashRunTime(const Duration(seconds: 5));
    // icubeInstallAndRegisterApp();
    AnalyticsService.logAppOpen();
    AnalyticsService.setCustCurrentScreen("Splash Screen");
  }

  LocalUserModal? localUserModal = MyStorage.getUserData();
  final api = DashboardAPi(DioApi(isHeader: false).sendRequest);
  final splashapi = SplashAPi(DioApi(isHeader: false).sendRequest);

  splashRunTime(Duration duration) async {
    try {
      // emit(AppStatusLoading());
      final res = await api.getAppStatus();

      if (res.response.statusCode == 200) {
        AppStatusModal model = AppStatusModal.fromJson(res.data);

        bool isLoggedIn = localUserModal?.responseData?.id != null ? true : false;
        bool isUserOnBoard = MyStorage.readData(MyStorageString.isUserOnBoard) ?? false;
        await Future.delayed(duration);

        final bool isUTMInstall = MyStorage.getUTMInstallDataUpdated() ?? false;
        SaveLogger.log("isUTMInstall1 Splash After::: $isUTMInstall");
        if (!isUTMInstall) {
          SaveLogger.log("isUTMInstall2 Splash After::: $isUTMInstall");

          final String source = MyStorage.getUTMSource() ?? "";
          final String transctionId = MyStorage.getUTMTransactionData() ?? "";
          final String deviceId = "";
          final String installTime = MyStorage.getUTMInstallTime() ?? "";
          final String version = MyStorage.getUTMVersion() ?? "";

          SaveLogger.log("isUTMInstall3 Splash After::: $isUTMInstall");
          if (source.isNotEmpty && transctionId.isNotEmpty) {
            icubeInstallAndRegisterApp(transaction_id: transctionId, goal_id: '7747');
            salaryNowInstallAndRegisterApp(
                utm_source: source,
                utm_medium: transctionId,
                install_time: installTime,
                device_id: deviceId,
                goal_name: MyStorageString.install,
                app_version: version);
          }
        }

        emit(SplashLoadedState(isLoggedIn: isLoggedIn, isUserOnBoard: isUserOnBoard, appStatusModal: model));
      } else {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        await Future.delayed(duration);

        emit(SplashErrorState(error: errorModal.responseMsg.toString()));
      }
    } on DioError catch (e, s) {
      await Future.delayed(duration);
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('Dio Error:splashRunTime:- $e');
      CrashlyticsApp().setCustomKey('FoundIn', 'splashRunTime');
      CrashlyticsApp().recordError(e, s);

      emit(SplashErrorState(error: handleDioError(e).toString()));
    }
  }

  icubeInstallAndRegisterApp(
      {String offer_id = '5074',
      String goal_id = '7747',
      String transaction_id = 'W000051',
      String adv_sub1 = 'promotion',
      String adv_sub2 = 'ads',
      String goal_name = MyStorageString.install}) async {
    try {
      Map<String, dynamic> queryParams = {
        'offer_id': offer_id,
        'goal_id': goal_id,
        'transaction_id': transaction_id,
        'adv_sub1': adv_sub1,
        'adv_sub2': adv_sub2
      };
      final res = await splashapi.getInstallAppStatus(queryParams);
      print("Hiting Api To Check Status- ${res.data}");

      SaveLogger.log("goal_name ::: $goal_name,$queryParams");
      SaveLogger.log("Hiting Api To Check Status ::: ${res.data},${res.response.statusCode}");
      if (res.response.statusCode == 200) {
        if (goal_name == MyStorageString.install) {
          MyStorage.setUTMInstallDataUpdated(true);
        }

        if (goal_name == MyStorageString.register) {
          MyStorage.setUTMIRegisterDataUpdated(true);
        }
        // AppStatusModal model = AppStatusModal.fromJson(res.data);
        //
        // bool isLoggedIn = localUserModal?.responseData?.id != null ? true : false;
        // bool isUserOnBoard = MyStorage.readData(MyStorageString.isUserOnBoard) ?? false;
        // // await Future.delayed(duration);
        //
        // emit(SplashLoadedState(isLoggedIn: isLoggedIn, isUserOnBoard: isUserOnBoard, appStatusModal: model));
      } else {
        // ErrorModal errorModal = ErrorModal.fromJson(res.data);
        // await Future.delayed(duration);
        //
        // emit(SplashErrorState(error: errorModal.responseMsg.toString()));
      }
    } on DioError catch (e) {
      // await Future.delayed(duration);
      //
      // emit(SplashErrorState(error: handleDioError(e).toString()));
    }
  }

  salaryNowInstallAndRegisterApp(
      {String utm_source = '',
      String utm_medium = '',
      String install_time = '',
      String device_id = '',
      String goal_name = MyStorageString.install,
      String app_version = ''}) async {
    try {
      Map<String, dynamic> queryParams = {
        'utm_source': utm_source,
        'utm_medium': utm_medium,
        'install_time': install_time,
        'device_id': device_id,
        'goal': goal_name,
        'app_version': app_version
      };
      final res = await api.postPromotion(queryParams);
      print("Checking API of Salary Now.- ${res.data}");
      SaveLogger.log("Salary Now Api Call back::: $queryParams, ${res.data}, ${res.response.statusCode}");
      if (res.response.statusCode == 200) {
        if (goal_name == MyStorageString.install) {
          MyStorage.setUTMInstallDataUpdated(true);
        }

        if (goal_name == MyStorageString.register) {
          MyStorage.setUTMIRegisterDataUpdated(true);
        }
      } else {}
    } on DioError catch (e) {}
  }
}
