import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:salarynow/registration/network/modal/pan_card_modal.dart';
import 'package:salarynow/storage/local_storage_strings.dart';
import 'package:salarynow/utils/crashlytics_app.dart';
import 'package:salarynow/utils/written_text.dart';
import '../../../service_helper/api/dio_api.dart';
import '../../../service_helper/error_helper.dart';
import '../../../service_helper/modal/error_modal.dart';
import '../../../storage/local_storage.dart';
import '../../network/api/registration_api.dart';
part 'pan_card_validation_state.dart';

class PanCardValidationCubit extends Cubit<PanCardValidationState> {
  PanCardValidationCubit() : super(PanCardValidationInitial());

  static PanCardValidationCubit get(context) => BlocProvider.of(context);

  final api = RegistrationApi(DioApi(isHeader: false).sendRequest);

  String appID = MyStorage.readData(MyStorageString.uuid);

  Future postPinCode({required String panCard}) async {
    try {
      emit(PanCardValidationStatus(status: false));
      emit(PanCardValidationLoading());
      final res = await api.postPanCard({"pan_number": panCard, "app_id": appID});

      if (res.response.statusCode == 200) {
        PanCardModal model = PanCardModal.fromJson(res.data);
        emit(PanCardValidationLoaded(panCardModal: model));
        emit(PanCardValidationStatus(status: true));
      } else {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(PanCardValidationError(error: errorModal.responseMsg.toString()));
        emit(PanCardValidationStatus(status: false));
      }
    } on DioError catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('DioError Error:postPinCode:- $e');
      CrashlyticsApp().setCustomKey('FoundIn', 'postPinCode');
      CrashlyticsApp().recordError(e, s);

      emit(PanCardValidationError(error: handleDioError(e).toString()));
    } catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('Other Error Error:postPinCode:- $e');
      CrashlyticsApp().setCustomKey('FoundIn', 'postPinCode');
      CrashlyticsApp().recordError(e, s);

      emit(PanCardValidationError(error: MyWrittenText.somethingWrong));
    }
  }
}
