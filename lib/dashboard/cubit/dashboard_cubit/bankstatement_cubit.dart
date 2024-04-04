import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:salarynow/dashboard/network/api/dashboard_api.dart';
import 'package:salarynow/dashboard/network/modal/bankstatement_model.dart';
import 'package:salarynow/dashboard/network/modal/dashboard_modal.dart';
import 'package:salarynow/required_document/network/modal/bank_statement_modal.dart';
import 'package:salarynow/utils/crashlytics_app.dart';

import '../../../service_helper/api/dio_api.dart';
import '../../../service_helper/error_helper.dart';
import '../../../service_helper/modal/error_modal.dart';
import '../../../storage/local_storage.dart';
import '../../../utils/written_text.dart';

part 'bankstatement_state.dart';

class BankstatementCubit extends Cubit<BankstatementState> {
  BankstatementCubit() : super(BankstatementInitial());
  String appVersion = "";

  static BankstatementCubit get(context) => BlocProvider.of(context);
  final api = DashboardAPi(DioApi(isHeader: true).sendRequest);

  Future getBankStatementData() async {
    try {
      emit(BankstatementLoading());
      final res = await api.getDashBoardBankStatementData();
      print("res.data ${res.data}");
      if (res.response.statusCode == 200) {
        BankStatmentModal model = BankStatmentModal.fromJson(res.data);
        // MyStorage.setDashBoardData(DashBoardModal.fromJson(res.data));

        emit(BankstatementLoaded(bankstatementModal: model));
      } else {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(BankstatementError(error: errorModal.responseMsg.toString()));
      }
    } on DioError catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('DioError:getBankStatementData:- ${e.message}');
      CrashlyticsApp().recordError(e, s);
      emit(BankstatementError(error: handleDioError(e).toString()));
    } catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('Other Error:getBankStatementData:- $e');
      CrashlyticsApp().recordError(e, s);
      emit(BankstatementError(error: MyWrittenText.somethingWrong));
    }
  }
}
