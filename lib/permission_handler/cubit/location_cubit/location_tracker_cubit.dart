import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salarynow/utils/written_text.dart';
import '../../../routing/route_path.dart';
import '../../../service_helper/api/dio_api.dart';
import '../../../service_helper/error_helper.dart';
import '../../../service_helper/modal/error_modal.dart';
import '../../../utils/on_screen_loader.dart';
import '../../api/permission_api.dart';
part 'location_tracker_state.dart';

class LocationTrackerCubit extends Cubit<LocationTrackerState> {
  LocationTrackerCubit() : super(LocationTrackerInitial());

  static LocationTrackerCubit get(context) => BlocProvider.of(context);

  final api = PermissionApi(DioApi(isHeader: true).sendRequest);

  Future<void> postLocation({
    required String loanNumber,
    required String location_from,
    required String status,
  }) async {
    emit(LocationTrackerLoading());
    PermissionStatus permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placeMarks[0];

      try {
        var data = {
          "latitude": position.latitude.toString(),
          "longitude": position.latitude.toString(),
          "address": getCompleteAddress(place: place),
          "nooffakeapplication": "None",
          "fakeenable": "None",
          "status": "Apply Loan Page",
          "loan_no": loanNumber
        };

        print("Post Location $data");
        final res = await api.postLocation(data);

        if (res.response.statusCode == 200) {
          ErrorModal successModal = ErrorModal.fromJson(res.data);
          emit(LocationTrackerLoaded(message: successModal.responseMsg.toString()));
        } else {
          ErrorModal errorModal = ErrorModal.fromJson(res.data);
          emit(LocationTrackerError(errorMessage: errorModal.responseMsg.toString()));
        }
      } on DioError catch (e) {
        emit(LocationTrackerError(errorMessage: handleDioError(e).toString()));
      } catch (e) {
        emit(LocationTrackerError(errorMessage: MyWrittenText.somethingWrong));
      }
    } else {
      emit(LocationTrackerError(errorMessage: 'Permission denied'));
    }
  }

  Future<void> postLocationWithoutResp(
      {required String loanNumber,
      required String location_from,
      required String status,
      required BuildContext mCtx}) async {
    if (location_from == "Registration") {
      MyScreenLoader.onScreenLoader(mCtx);
    }
    PermissionStatus permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placeMarks[0];

      try {
        var data = {
          "latitude": position.latitude.toString(),
          "longitude": position.longitude.toString(),
          "address": getCompleteAddress(place: place),
          "nooffakeapplication": "None",
          "fakeenable": "None",
          "status": status,
          "location_from": location_from,
          "loan_no": loanNumber
        };

        final res = await api.postLocation(data);
        if (location_from == "Registration") {
          Navigator.pop(mCtx);
          Navigator.pushNamed(mCtx, RoutePath.govtAadhaarScreen, arguments: {
            'isApplyScreen': false,
            'isDashBoardScreen': true,
            'isNotComeFromRegiScreen': false,
          });
        }
      } catch (e) {
        if (location_from == "Registration") {
          Navigator.pop(mCtx);
          Navigator.pushNamed(mCtx, RoutePath.govtAadhaarScreen, arguments: {
            'isApplyScreen': false,
            'isDashBoardScreen': true,
            'isNotComeFromRegiScreen': false,
          });
        }
      }
    } else {
      if (location_from == "Registration") {
        Navigator.pop(mCtx);
        Navigator.pushNamed(mCtx, RoutePath.govtAadhaarScreen, arguments: {
          'isApplyScreen': false,
          'isDashBoardScreen': true,
          'isNotComeFromRegiScreen': false,
        });
      }
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
}
