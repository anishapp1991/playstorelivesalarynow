part of 'profile_cubit.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileModal profileModal;
  ProfileLoaded({required this.profileModal});
}

class ProfileError extends ProfileState {
  final String error;
  ProfileError({required this.error});
}





// selfi
class SelfieInitial extends ProfileState {}

class SelfieLoadingState1 extends ProfileState {}

class SelfieLoadedState1 extends ProfileState {
  final File file;
  final Position position;
  final String place;
  SelfieLoadedState1({required this.file, required this.position, required this.place});
}

class SelfieErrorState1 extends ProfileState {
  final String error;
  SelfieErrorState1({required this.error});
}

class GetSelfieLoadingState1 extends ProfileState {}

class GetSelfieLoadedState1 extends ProfileState {
  final String imageUrl;
  GetSelfieLoadedState1({required this.imageUrl});
}

class GetSelfieErrorState1 extends ProfileState {
  final String error;
  GetSelfieErrorState1({required this.error});
}