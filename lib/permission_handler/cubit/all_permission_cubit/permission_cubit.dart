import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
part 'permission_state.dart';

class PermissionCubit extends Cubit<PermissionState> {
  PermissionCubit() : super(PermissionInitial());

  static PermissionCubit get(context) => BlocProvider.of(context);

  final log = Logger();

  Future<void> reqAllPermission() async {
    emit(AllPermissionLoading());

    PermissionStatus permissionPhoneStatus = await Permission.phone.request();
    PermissionStatus permissionSmsStatus = await Permission.sms.request();
    PermissionStatus permissionCameraStatus = await Permission.camera.request();
    PermissionStatus permissionLocationStatus = await Permission.location.request();

    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.phone,
        Permission.sms,
        Permission.camera,
        Permission.location,
      ].request();
      print(
        "phone permission: ${statuses[Permission.phone]}, "
        "sms permission: ${statuses[Permission.sms]}, "
        "camera permission: ${statuses[Permission.camera]}, "
        "location permission: ${statuses[Permission.location]}",
      );

      if (permissionPhoneStatus.isGranted &&
          permissionSmsStatus.isGranted &&
          permissionLocationStatus.isGranted &&
          permissionCameraStatus.isGranted) {
        emit(AllPermissionGranted());
      } else {
        emit(AllPermissionDenied(
          allowPhonePermission: permissionPhoneStatus.isGranted,
          allowSmsPermission: permissionSmsStatus.isGranted,
          allowCameraPermission: permissionCameraStatus.isGranted,
          allowLocationPermission: permissionLocationStatus.isGranted,
        ));
      }
    } catch (e) {
      throw getError(e);
    }
  }

  Future<void> reqPhonePermission() async {
    PermissionStatus permissionStatus = await Permission.phone.request();
    if (permissionStatus == PermissionStatus.granted) {
      emit(PhonePermissionGranted());
    } else {
      emit(PhonePermissionDenied(denied: 'Phone Permission Denied'));
    }
  }

  Future<void> reqContactsPermission() async {
    PermissionStatus permissionStatus = await Permission.contacts.request();
    if (permissionStatus == PermissionStatus.granted) {
      emit(ContactPermissionGranted());
    } else {
      emit(ContactPermissionDenied(denied: 'Contact Permission Denied'));
    }
  }

  Future<void> reqSMSPermission() async {
    PermissionStatus permissionStatus = await Permission.sms.request();
    if (permissionStatus == PermissionStatus.granted) {
      emit(SmsPermissionGranted());
    } else {
      emit(SmsPermissionDenied(denied: 'Sms Permission Denied'));
    }
  }

  Future<void> reqCameraPermission() async {
    PermissionStatus permissionStatus = await Permission.camera.request();
    if (permissionStatus == PermissionStatus.granted) {
      emit(CameraPermissionGranted());
    } else {
      emit(CameraPermissionDenied(denied: 'Camera Permission Denied'));
    }
  }

  Future<void> reqStoragePermission() async {
    PermissionStatus permissionStatus = await Permission.storage.request();
    if (permissionStatus == PermissionStatus.granted) {
      emit(StoragePermissionGranted());
    } else {
      emit(StoragePermissionDenied(denied: 'Storage Permission Denied'));
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

  Future<void> getCurrentLocation() async {
    emit(CurrentLocationLoading());
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placeMarks[0];
      emit(CurrentLocationLoaded(position: position, place: place));
    } catch (e) {
      emit(CurrentLocationError(error: e.toString()));
      throw getError(e);
    }
  }

  getError(Object object) {
    log.e(object.toString());
  }

  @override
  Future<void> close() {
    reqAllPermission();
    reqCameraPermission();
    reqContactsPermission();
    reqLocationPermission();
    reqPhonePermission();
    reqSMSPermission();
    reqStoragePermission();
    return super.close();
  }
}
