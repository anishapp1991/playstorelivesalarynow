import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:salarynow/information/network/modal/banking_detail_modal.dart';
import 'package:salarynow/service_helper/error_helper.dart';
import 'package:salarynow/utils/crashlytics_app.dart';
import 'package:salarynow/utils/written_text.dart';
import '../../../service_helper/api/dio_api.dart';
import '../../../service_helper/modal/error_modal.dart';
import '../../network/api/banking_api/banking_detail_api.dart';

part 'banking_detail_state.dart';

class BankingDetailCubit extends Cubit<BankingDetailState> {
  BankingDetailCubit() : super(BankingDetailInitial()) {
    getBankDetails();
  }
  static BankingDetailCubit get(context) => BlocProvider.of(context);

  final api = BankingDetailApi(DioApi(isHeader: true).sendRequest);

  Future getBankDetails() async {
    try {
      emit(BankingDetailLoading());
      final res = await api.getBankDetails();

      if (res.response.statusCode == 200) {
        BankDetailsModal model = BankDetailsModal.fromJson(res.data);
        emit(BankingDetailLoaded(bankingDetailsModal: model));
      } else {
        ErrorModal errorModal = ErrorModal.fromJson(res.data);
        emit(BankingDetailError(error: errorModal.responseMsg.toString()));
      }
    } on DioError catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('DioError:getBankDetails:- ${e.message}');
      CrashlyticsApp().setCustomKey('FoundIn', 'getBankDetails');
      CrashlyticsApp().recordError(e, s);

      emit(BankingDetailError(error: handleDioError(e)));
    } catch (e, s) {
      CrashlyticsApp().setUserIdentifier("");
      CrashlyticsApp().log('Other Error:getBankDetails:- $e');
      CrashlyticsApp().setCustomKey('FoundIn', 'getBankDetails');
      CrashlyticsApp().recordError(e, s);

      emit(BankingDetailError(error: MyWrittenText.somethingWrong));
    }
  }

  @override
  Future<void> close() {
    getBankDetails();
    return super.close();
  }
}
