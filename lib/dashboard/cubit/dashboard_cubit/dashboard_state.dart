part of 'dashboard_cubit.dart';

@immutable
abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashBoardModal dashBoardModal;
  DashboardLoaded({required this.dashBoardModal});
}

class DashboardError extends DashboardState {
  final String error;
  DashboardError({required this.error});
}



class BankstatementInitial extends DashboardState {}

class BankstatementLoading extends DashboardState {}

class BankstatementLoaded extends DashboardState {
  final BankStatmentModal bankstatementModal;
  BankstatementLoaded({required this.bankstatementModal});
}

class BankstatementError extends DashboardState {
  final String error;
  BankstatementError({required this.error});
}
