
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:salarynow/dashboard/network/modal/not_interested_modal.dart';
import 'package:salarynow/utils/crashlytics_app.dart';
import 'package:salarynow/utils/written_text.dart';
import '../../../service_helper/api/dio_api.dart';
import '../../../service_helper/error_helper.dart';
import '../../../service_helper/modal/error_modal.dart';
import '../../network/api/dashboard_api.dart';
part 'not_interested_state.dart';

class NotInterestedCubit extends Cubit<NotInterestedState> {
  NotInterestedCubit() : super(NotInterestedInitial()) {
    getNotInterestedData();
  }

  static NotInterestedCubit get(context) => BlocProvider.of(context);
  final api = DashboardAPi(DioApi(isHeader: true).sendRequest);

  Future getNotInterestedData() async {
    try {
      emit(NotInterestedLoading());
      final res = await api.getNotInterested();

      if (res.response.statusCode == 200) {
        NotInterestedModal model = NotInterestedModal.fromJson(res.data);
        emit(NotInterestedLoaded(modal: model));
      } else {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(NotInterestedError(error: errorModal.responseMsg.toString()));
      }
    } on DioError catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('DioError:getNotInterestedData:- ${e.message}');
      CrashlyticsApp().setCustomKey('FoundIn', 'getNotInterestedData');
      CrashlyticsApp().recordError(e, s);

      emit(NotInterestedError(error: handleDioError(e).toString()));
    } catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('Other Error:getNotInterestedData:- $e');
      CrashlyticsApp().setCustomKey('FoundIn', 'getNotInterestedData');
      CrashlyticsApp().recordError(e, s);

      emit(NotInterestedError(error: MyWrittenText.somethingWrong));
    }
  }
}
