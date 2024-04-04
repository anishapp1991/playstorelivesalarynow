part of 'bankstatement_cubit.dart';

@immutable
abstract class BankstatementState {}

// class DashboardInitial extends DashboardState {}
//
// class DashboardLoading extends DashboardState {}
//
// class DashboardLoaded extends DashboardState {
//   final DashBoardModal dashBoardModal;
//   DashboardLoaded({required this.dashBoardModal});
// }
//
// class DashboardError extends DashboardState {
//   final String error;
//   DashboardError({required this.error});
// }



class BankstatementInitial extends BankstatementState {}

class BankstatementLoading extends BankstatementState {}

class BankstatementLoaded extends BankstatementState {
  final BankStatmentModal bankstatementModal;
  BankstatementLoaded({required this.bankstatementModal});
}

class BankstatementError extends BankstatementState {
  final String error;
  BankstatementError({required this.error});
}
