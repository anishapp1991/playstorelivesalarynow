import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:salarynow/packages/network/modal/apply_loan_modal.dart';
import 'package:salarynow/utils/crashlytics_app.dart';
import 'package:salarynow/utils/written_text.dart';
import '../../../service_helper/api/dio_api.dart';
import '../../../service_helper/error_helper.dart';
import '../../../service_helper/modal/error_modal.dart';
import '../../network/api/packages_api.dart';

part 'apply_loan_state.dart';

class ApplyLoanCubit extends Cubit<ApplyLoanState> {
  ApplyLoanCubit() : super(ApplyLoanInitial());

  static ApplyLoanCubit get(context) => BlocProvider.of(context);

  final api = PackagesApi(DioApi(isHeader: true).sendRequest);

  Future postApplyLoan({
    String? loanTenure,
    String? loanAmount,
    String? interestAmount,
    String? totalPayAmount,
    String? loanPurpose,
    String? productId,
  }) async {
    // emit(ApplyLoanLoading());
    // var data = {
    //     "loan_amt": loanAmount,
    //     "loan_teneur": loanTenure,
    //     "interest_amt": interestAmount,
    //     "Total_Pay_Amount": totalPayAmount,
    //     "loan_purpose": loanPurpose,
    //     "productId": productId
    //   };
    // ApplyLoanModal model = ApplyLoanModal.fromJson(data);
    // emit(ApplyLoanLoaded(applyLoanModal: model));
    try {
      emit(ApplyLoanLoading());

      var data = {
        "loan_amt": loanAmount,
        "loan_teneur": loanTenure,
        "interest_amt": interestAmount,
        "Total_Pay_Amount": totalPayAmount,
        "loan_purpose": loanPurpose,
        "productId": productId
      };

      CrashlyticsApp().setCustomKey('Request', 'postApplyLoan -$data');
      final res = await api.postApplyLoan(data);
      CrashlyticsApp().setCustomKey('Body', 'postApplyLoan -${res.data}');
      if (res.response.statusCode == 200) {
        ApplyLoanModal model = ApplyLoanModal.fromJson(res.data);
        emit(ApplyLoanLoaded(applyLoanModal: model));
      } else {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(ApplyLoanError(
          error: errorModal,
        ));
      }
    } on DioError catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('DioError:postApplyLoan:- $e');
      CrashlyticsApp().recordError(e, s);

      emit(ApplyLoanError(
        error: ErrorModal(responseMsg: handleDioError(e).toString(), responseCode: 0, responseStatus: 0),
      ));
    } catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('Other Error:postApplyLoan:- $e');
      CrashlyticsApp().recordError(e, s);

      emit(ApplyLoanError(
          error: ErrorModal(responseMsg: MyWrittenText.somethingWrong, responseStatus: 0, responseCode: 0)));
    }
  }
}
