import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:salarynow/dashboard/network/modal/update_micro_status_modal.dart';
import 'package:salarynow/service_helper/modal/error_modal.dart';
import 'package:salarynow/utils/crashlytics_app.dart';
import 'package:salarynow/utils/written_text.dart';

import '../../../../service_helper/api/dio_api.dart';
import '../../../../service_helper/error_helper.dart';
import '../../../network/api/dashboard_api.dart';
import '../../post_not_interested/post_not_intrested_cubit.dart';

part 'update_micro_status_state.dart';

class UpdateMicroStatusCubit extends Cubit<UpdateMicroStatusState> {
  UpdateMicroStatusCubit() : super(UpdateMicroStatusInitial());

  static UpdateMicroStatusCubit get(context) => BlocProvider.of(context);
  final api = DashboardAPi(DioApi(isHeader: true).sendRequest);

  Future postMicroStatus({required String microStatus}) async {
    try {
      emit(UpdateMicroStatusLoading());
      final res = await api.postMicroStatus({"micro_status": microStatus});

      if (res.response.statusCode == 200) {
        UpdateMicroStatusModal model = UpdateMicroStatusModal.fromJson(res.data);
        emit(UpdateMicroStatusLoaded(updateMicroStatusModal: model));
      } else if (res.response.statusCode == 400) {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(UpdateMicroStatusError(error: errorModal.responseMsg.toString()));
      }
    } on DioError catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('DioError:postMicroStatus:- ${e.message}');
      CrashlyticsApp().setCustomKey('FoundIn', 'postMicroStatus');
      CrashlyticsApp().recordError(e, s);

      emit(UpdateMicroStatusError(error: handleDioError(e).toString()));
    } catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('Other Error:postMicroStatus:- $e');
      CrashlyticsApp().setCustomKey('FoundIn', 'postMicroStatus');
      CrashlyticsApp().recordError(e, s);

      emit(UpdateMicroStatusError(error: MyWrittenText.somethingWrong));
    }
  }
}
