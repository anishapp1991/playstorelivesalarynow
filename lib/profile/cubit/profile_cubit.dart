import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:salarynow/profile/network/api/profile_api.dart';
import 'package:salarynow/profile/network/modal/profile_modal.dart';
import 'package:salarynow/service_helper/api/dio_api.dart';
import 'package:salarynow/storage/local_storage.dart';
import 'package:salarynow/storage/local_user_modal.dart';
import 'package:salarynow/utils/crashlytics_app.dart';
import 'package:salarynow/utils/written_text.dart';
import '../../required_document/cubit/req_doc_cubit/req_document_cubit.dart';
import '../../service_helper/error_helper.dart';
import '../../service_helper/modal/error_modal.dart';
import '../../utils/color.dart';
import '../../widgets/dialog_box_widget.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  static ProfileCubit get(context) => BlocProvider.of(context);

  final api = ProfileApi(DioApi(isHeader: true).sendRequest);

  Future getProfile() async {
    try {
      emit(ProfileLoading());
      final res = await api.getProfile();

      if (res.response.statusCode == 200) {
        ProfileModal model = ProfileModal.fromJson(res.data);
        emit(ProfileLoaded(profileModal: model));
      } else {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(ProfileError(error: errorModal.responseMsg.toString()));
      }
    } on DioError catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('DiaError:getProfile:- $e');
      CrashlyticsApp().setCustomKey('FoundIn', 'getProfile');
      CrashlyticsApp().recordError(e, s);

      emit(ProfileError(error: handleDioError(e).toString()));
    } catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('Others Error:getProfile:- $e');
      CrashlyticsApp().setCustomKey('FoundIn', 'getProfile');
      CrashlyticsApp().recordError(e, s);

      emit(ProfileError(error: MyWrittenText.somethingWrong));
    }
  }

  String getCompleteAddress({required Placemark place}) {
    return "${place.name!.isNotEmpty ? place.name : ""},"
        "${place.street!.isNotEmpty ? place.street : ""},"
        "${place.subLocality!.isNotEmpty ? place.subLocality : ""},"
        "${place.locality!.isNotEmpty ? place.locality : ""},"
        "${place.administrativeArea!.isNotEmpty ? place.administrativeArea : ""},"
        "${place.subAdministrativeArea!.isNotEmpty ? place.subAdministrativeArea : ""},"
        "${place.postalCode!.isNotEmpty ? place.postalCode : ""},"
        "${place.isoCountryCode!.isNotEmpty ? place.isoCountryCode : ""},"
        "${place.country!.isNotEmpty ? place.country : ""},"
        "${place.thoroughfare!.isNotEmpty ? place.thoroughfare : ""},"
        "${place.subThoroughfare!.isNotEmpty ? place.subThoroughfare : ""}";
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
