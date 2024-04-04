import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../service_helper/api/dio_api.dart';
import '../../../service_helper/error_helper.dart';
import '../../../service_helper/modal/error_modal.dart';
import '../../../utils/crashlytics_app.dart';
import '../../../utils/written_text.dart';
import '../../network/api/dashboard_api.dart';
import '../../network/modal/loan_agreement_data_model.dart';
import 'loan_agreement_state.dart';

class LoanAgreementCubit extends Cubit<LoanAgreementState> {
  LoanAgreementCubit() : super(LoanAgreementInitial());

  static LoanAgreementCubit get(context) => BlocProvider.of(context);
  final api = DashboardAPi(DioApi(isHeader: true).sendRequest);

  Future getLoanAgreementData() async {
    print("Called Api Function of GetLoanAgreement Data");
    try {
      emit(LoanAgreementWebLoading());
      final res = await api.getLoanAgreementData();
      if (res.response.statusCode == 200) {
        LoanAgreementDataModel model = LoanAgreementDataModel.fromJson(res.data);

        emit(LoanAgreementLoaded(loanAgreementDataModel: model));
      } else {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(LoanAgreementError(error: errorModal.responseMsg.toString()));
      }
    } on DioError catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('DioError:getDashBoardData:- ${e.message}');
      CrashlyticsApp().setCustomKey('ErrorType', 'DioError');
      CrashlyticsApp().recordError(e, s);
      emit(LoanAgreementError(error: handleDioError(e).toString()));
    } catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('Other Error:getDashBoardData:- $e');
      CrashlyticsApp().setCustomKey('ErrorType', 'OtherError');
      CrashlyticsApp().recordError(e, s);
      emit(LoanAgreementError(error: MyWrittenText.somethingWrong));
    }
  }
}
