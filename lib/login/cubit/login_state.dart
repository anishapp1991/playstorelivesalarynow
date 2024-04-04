part of 'login_cubit.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginLoadedState extends LoginState {
  final LoginModal loginModal;
  LoginLoadedState(this.loginModal);
}

class LoginLoadedOtpState extends LoginState {
  final LoginModal loginModal;
  LoginLoadedOtpState(this.loginModal);
}

class LoginErrorState extends LoginState {
  final String error;
  LoginErrorState(this.error);
}

// otp
class OtpInitial extends LoginState {}

class OtpLoadingState extends LoginState {}

class OtpLoadedState extends LoginState {
  final LoginVerifyModal loginVerifyModal;
  OtpLoadedState({required this.loginVerifyModal});
}

class CallVerifyLoadingState extends LoginState {}

class CallVerifyLoadedState extends LoginState {
  final LoginVerifyCallModal loginVerifyCallModal;
  CallVerifyLoadedState({required this.loginVerifyCallModal});
}

class CallVerifyCallBackLoadedState extends LoginState {
  final LoginVrCallBackModal loginVrCallBackModal;
  final String? callersid;
  CallVerifyCallBackLoadedState({required this.loginVrCallBackModal, this.callersid});
}

class VRCallErrorState extends LoginState {
  final String? error;
  final String? callersid;
  VRCallErrorState(
    this.error,
    this.callersid,
  );
}

class OtpErrorState extends LoginState {
  final String? error;
  OtpErrorState(
    this.error,
  );
}
