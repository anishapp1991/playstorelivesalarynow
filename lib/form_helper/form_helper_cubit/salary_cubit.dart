import 'package:flutter_bloc/flutter_bloc.dart';

class SalaryCubit extends Cubit<bool> {
  SalaryCubit() : super(false);

  void checkApprovalStatus(double salary) {
    if(salary == -1.0 || salary == 0.0) {
      emit(true);
    }else if (salary < 25000) {
      emit(false);
    } else {
      emit(true);
    }
  }

  @override
  Future<void> close() {
    checkApprovalStatus(0);
    return super.close();
  }
}
