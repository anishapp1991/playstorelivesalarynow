import 'package:bloc/bloc.dart';
import 'package:device_information/device_information.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salarynow/storage/local_storage.dart';
import 'package:salarynow/storage/local_storage_strings.dart';
import 'package:salarynow/utils/crashlytics_app.dart';
import 'package:salarynow/widgets/dialog_box_widget.dart';

part 'imei_state.dart';

class ImeiCubit extends Cubit<ImeiState> {
  final BuildContext context;
  ImeiCubit(this.context) : super(ImeiInitial());

  static ImeiCubit get(context) => BlocProvider.of(context);

  Future<void> getImeiNumber(BuildContext context, String mobile) async {
    PermissionStatus permissionStatus = await Permission.phone.request();
    print("permissionStatus - $permissionStatus");
    if (permissionStatus == PermissionStatus.granted) {
      try {
        String imeiNo = await DeviceInformation.deviceIMEINumber;
        String androidVersion = await DeviceInformation.platformVersion;
        MyStorage.writeData(MyStorageString.imei, imeiNo);
        MyStorage.writeData(MyStorageString.androidVersion, androidVersion);
        emit(ImeiNumberLoaded(imeiNumber: imeiNo));
      } on PlatformException catch (e, stack) {
        emit(ImeiNumberError(error: 'Please Allow Phone Permission'));
        getError(e);
      }
    } else {
      MyDialogBox.requestPermissionPhone(context: context);
      emit(ImeiNumberError(error: 'Please Allow Phone Permission'));
    }
  }

  getError(Object object) {
    // log.e(object.toString());
  }

  @override
  Future<void> close() {
    getImeiNumber(context, "");
    return super.close();
  }
}
