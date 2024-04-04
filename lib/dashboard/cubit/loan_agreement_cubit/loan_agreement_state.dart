import 'package:flutter/material.dart';
import 'package:salarynow/dashboard/network/modal/loan_agreement_data_model.dart';
import '../../network/modal/dashboard_modal.dart';

@immutable
abstract class LoanAgreementState {}

class LoanAgreementInitial extends LoanAgreementState {}

class LoanAgreementWebLoading extends LoanAgreementState {}

class LoanAgreementLoaded extends LoanAgreementState {
  final LoanAgreementDataModel loanAgreementDataModel;
  LoanAgreementLoaded({required this.loanAgreementDataModel});
}

class LoanAgreementError extends LoanAgreementState {
  final String error;
  LoanAgreementError({required this.error});
}
